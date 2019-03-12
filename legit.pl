#!/usr/bin/perl -w

use File::Copy;
use File::Compare;

use Legit_Helpers;
use Legit_Branch;

# Setup a script name without ./
$script_name = "legit.pl";
# Location of files
$commit_files_dir = ".legit/commit_files";
# If no arguments then show usage and exit
if($#ARGV == -1) {
  ::show_usage();
}
# If first argument doesnt match valid command then show usage and exit
my $cmd = shift @ARGV;
if(::valid_commands($cmd) == 0) {
  if(length $cmd > 0) {
    print STDERR "$script_name: error: unknown command $cmd\n";
  }
  ::show_usage();
  exit 1;
}

if($cmd eq "init") {
  ::init_command();
}
if($cmd eq "add") {
  ::add_command();
}
if($cmd eq "commit") {
  ::commit_command();
}
if($cmd eq "log") {
  ::log_command();
}
if($cmd eq "show") {
  ::show_command();
}
if($cmd eq "status") {
  ::status_command();
}
if($cmd eq "rm") {
  ::rm_command();
}
if($cmd eq "branch") {
  Legit_Branch::branch_command();
}
if($cmd eq "checkout") {
  Legit_Branch::checkout_command();
}

sub show_usage {
  print STDERR "Usage: $script_name <command> [<args>]

These are the legit commands:
   init       Create an empty legit repository
   add        Add file contents to the index
   commit     Record changes to the repository
   log        Show commit log
   show       Show file at particular state
   rm         Remove files from the current directory and from the index
   status     Show the status of files in the current directory, index, and repository
   branch     list, create or delete a branch
   checkout   Switch branches or restore current directory files
   merge      Join two development histories together

";
  exit 1;
}

sub valid_commands {
  my ($cmd) = @_;
  my %commands = (
    "init"  => 1,
    "add" => 1,
    "commit" => 1,
    "log" => 1,
    "show" => 1,
    "status" => 1,
    "rm" => 1,
    "branch" => 1,
    "checkout" => 1,
  );
  return defined $commands{$cmd} ? $commands{$cmd} : 0;
}

sub init_command {
  my $init_dir = ".legit";
  # Error case when more than one argument provided
  if($#ARGV != -1) {
    print STDERR "usage: $script_name init\n";
    exit 1;
  }
  # Error case when dir already exists
  if( -e $init_dir) {
    print STDERR "$script_name: error: $init_dir already exists\n";
    exit 1;
  }
  # Make .legit dir and an empty index file or error
  mkdir $init_dir or (print STDERR "$script_name: error: could not create legit depository\n" and exit 1);
  mkdir "$init_dir/commit_struct" or (print STDERR "$script_name: error: could not create legit depository\n" and exit 1);
  mkdir "$init_dir/commit_files" or (print STDERR "$script_name: error: could not create legit depository\n" and exit 1);
  open my $f, ">", "$init_dir/commit_struct/index" or (print STDERR "$script_name: error: could not create legit depository\n" and exit 1);
  print $f "";
  close $f;
  my %commit_meta = (
    "current_commit" => 0,
    "current_branch" => "master",
    "branches" => {"master" => "master"},
  );
  Legit_Helpers::save_commit_meta(%commit_meta);
  print "Initialized empty legit repository in $init_dir\n";
}

sub add_files_to_index {
  my (@all_files) = @_;

  # Load current index into hash
  my ($commit_num, $prev_num, %index) = Legit_Helpers::load_index();
  %files_to_add = ();
  
  # Check if all files valid
  # Add new files to hash (this will remove dupes)
  foreach my $file (@all_files) {
    if($file =~ /^-/) {
      print STDERR "usage: $script_name add <filenames>\n";
      exit 1;
    }
    # Check file has invalid chars
    Legit_Helpers::validate_filename($file);
    if(! defined $index{$file} || ($index{$file} ne "index" && $index{$file} == -2) || ($index{$file} eq "index" && -f $file)) {
      # Check if the file exists
      if( ! -f $file) {
        print STDERR "$script_name: error: can not open '$file'\n";
        exit 1;
      }
      $index{$file} = "index";
      $files_to_add{$file} = 1;
    } else {
      # If file doesn't exist then this must be a delete operation
      if( ! -f $file) {
        # Check if the file has been committed yet or just added to index
        if($index{$file} eq "index") {
          delete $index{$file};
        } else {
          $index{$file} = -1;
        }
      } else {
        $index{$file} = $commit_num;
        $files_to_add{$file} = 1;
      }
    }
  }
  
  # Write the hash to index, also copy files into staging area
  #my $prev_num = $commit_num - 1;
  my %prev_commit;
  %prev_commit = Legit_Helpers::load_commit_struct($prev_num) if $commit_num > 0;
  my $commit_dir = "$commit_files_dir/$commit_num";
  if( ! -d $commit_dir) {
    mkdir $commit_dir or (print STDERR "$script_name: error: could not create commit folder\n" and exit 1);
  }
  foreach my $file (keys %index) {
    if($index{$file} eq "index") {
      copy $file, "$commit_dir/$file" if defined $files_to_add{$file};
    } elsif($index{$file} == $commit_num) {
      if(! defined $prev_commit{$file} || compare($file, "$commit_files_dir/$prev_commit{$file}/$file") != 0) {
        copy $file, "$commit_dir/$file" if defined $files_to_add{$file};
      } else {
        $index{$file} = $prev_commit{$file};
        unlink "$commit_dir/$file";
      }
    } elsif($index{$file} == -1) {
      unlink "$commit_dir/$file";
    }
  }
  Legit_Helpers::save_index(%index);
  return %index;
}

sub add_command {
  Legit_Helpers::check_init();
  
  # Check at least one file to add
  if($#ARGV < 0) {
    print STDERR "$script_name: error: internal error Nothing specified, nothing added.
Maybe you wanted to say 'git add .'?

You are not required to detect this error or produce this error message.\n";
    exit 1;
  }
  
  ::add_files_to_index(@ARGV);
}

sub commit_command {
  Legit_Helpers::check_init();
  
  # Check if correct arguments were provided
  my $commit_message;
  my $a_option = 0;
  while($#ARGV >= 0) {
    if($ARGV[0] eq '-a') {
      shift @ARGV;
      $a_option = 1;
    } elsif($ARGV[$#ARGV] eq '-a') {
      pop @ARGV;
      $a_option = 1;
    } elsif($#ARGV >= 1 && $ARGV[1] =~ /^[^\-]/ && $ARGV[0] eq '-m') {
      shift @ARGV;
      $commit_message = shift @ARGV;
    } else {
      last;
    }
  }
  if($#ARGV >= 0 || ! defined $commit_message) {
    print STDERR "usage: $script_name commit [-a] -m commit-message\n";
    exit 1;
  }

  # Load current index into hash
  my ($commit_num, $prev_commit, %index) = Legit_Helpers::load_index();
  my $commit_dir = "$commit_files_dir/$commit_num";
  my $changes_made = 0;
  
  # Add all files in index to index before commit if -a option set
  if($a_option == 1) {
    my @all_files = ();
    foreach my $file (keys %index) {
      if($index{$file} eq "index" || $index{$file} >= 0) {
        push @all_files, $file;
      }
    }
    %index = ::add_files_to_index(@all_files);
  }

  # Iterate through index files, if file has been added and has changed then commit
  foreach my $file (keys %index) {
    if($index{$file} eq "index") {
      $index{$file} = $commit_num;
      $changes_made = 1;
    } elsif($index{$file} == $commit_num && -f "$commit_dir/$file") {
      $changes_made = 1;
    } elsif($commit_num > 0 && $index{$file} < 0) {
      $changes_made = 1;
    }
  }

  if($changes_made == 1) {
    # Add message to commits
    Legit_Helpers::add_commit_message($commit_message);
    
    print "Committed as commit $commit_num\n";
    # Update commit struct
    Legit_Helpers::save_commit_struct($commit_num, %index);
    Legit_Helpers::commit_to_index($commit_num);
  } else {
    print "nothing to commit\n";
  }
}

sub log_command {
  Legit_Helpers::check_init();
  Legit_Helpers::check_commits();
  
  my %commit_meta = Legit_Helpers::load_commit_meta();
  my $current_branch = $commit_meta{"current_branch"};
  foreach my $commit_num (sort {$b <=> $a} keys %{$commit_meta{"commits"}{$current_branch}}) {
    my $commit_message = $commit_meta{"commits"}{$current_branch}{$commit_num};
    print "$commit_num $commit_message\n";
  }
}

sub show_command {
  Legit_Helpers::check_init();
  
  my $commit_num = Legit_Helpers::check_commits();
  
  # Check if correct arguments were provided
  if($#ARGV != 0) {
    print STDERR "usage: $script_name show <commit>:<filename>\n";
    exit 1;
  }
  
  # Split argument into parts and check if correct parts were given
  my $to_show = shift @ARGV;
  if($to_show =~ /([^:]*):(.*)/) {
    my $commit = $1;
    my $filename = $2;
    
    # Check commit valid if not empty
    if(length $commit > 0) {
      if($commit =~ /.*[^0-9].*/ || $commit < 0 || $commit >= $commit_num) {
        print STDERR "$script_name: error: unknown commit '$commit'\n";
        exit 1;
      }
    }
    # Check filename is valid
    Legit_Helpers::validate_filename($filename);
    
    # Load commit struct into hash
    my $struct_to_load = "index";
    my $files_dir = $commit_num;
    if(length $commit > 0) {
      $struct_to_load = $commit;
      $files_dir = $commit;
    }
    my %index = Legit_Helpers::load_commit_struct($struct_to_load);
  
    # Check filename is in index
    if( ! defined $index{$filename} || ($index{$filename} ne "index" && $index{$filename} < 0)) {
      if(length $commit > 0) {
        print STDERR "$script_name: error: '$filename' not found in commit $commit\n";
      } else {
        print STDERR "$script_name: error: '$filename' not found in index\n";
      }
      exit 1;
    } else {
      my $commit_dir = "$commit_files_dir/";
      if($index{$filename} eq "index") {
        $commit_dir .= $files_dir;
      } else {
        $commit_dir .= $index{$filename};
      }
      open my $f, "<", "$commit_dir/$filename" or (print STDERR "$script_name: error: could not open file $filename to show contents\n" and exit 1);
      print <$f>;
      close $f;
    }
  } else {
    print STDERR "$script_name: error: invalid object $to_show\n";
    exit 1;
  }
}

sub status_command {
  Legit_Helpers::check_init();
  Legit_Helpers::check_commits();

  # Load index and also get files in current dir using glob
  my ($commit_num, $prev_num, %index) = Legit_Helpers::load_index();
  my @dir_files = glob '"*"';
  foreach my $dir_file (@dir_files) {
    if( ! defined $index{$dir_file} && Legit_Helpers::validate_filename($dir_file, 1)) {
      $index{$dir_file} = "untracked";
    }
  }
  
  # Get the previous commit structure if there was one, for comparison
  #my $prev_num = $commit_num - 1;
  my %prev_commit = Legit_Helpers::load_commit_struct($prev_num);
  
  # Go through files in alphabetic order and determine status
  foreach my $file (sort keys %index) {
    if($index{$file} eq "untracked" || ($index{$file} ne "index" && $index{$file} == -2 && -f $file)) {
      print "$file - untracked\n";
    } elsif($index{$file} eq "index") {
      print "$file - added to index\n";
    } elsif($index{$file} < 0) {
      if(defined $prev_commit{$file}) {
        print "$file - deleted\n";
      }
    } elsif($index{$file} >= 0 && ! -f $file) {
      print "$file - file deleted\n";
    } else {
      # Compare index file with previous commit
      my $changed_prev_commit = defined $prev_commit{$file} ? compare("$commit_files_dir/$prev_commit{$file}/$file", "$commit_files_dir/$index{$file}/$file") : -1;
      # Compare index file with current directory
      my $changed_cur_dir = compare($file, "$commit_files_dir/$index{$file}/$file");
      if($changed_prev_commit != 0 && $changed_cur_dir != 0) {
        print "$file - file changed, different changes staged for commit\n";
      } elsif($changed_prev_commit != 0 && $changed_cur_dir == 0) {
        print "$file - file changed, changes staged for commit\n";
      } elsif($changed_prev_commit == 0 && $changed_cur_dir != 0) {
        print "$file - file changed, changes not staged for commit\n";
      } else {
        print "$file - same as repo\n";
      }
    }
  }
}

sub get_rm_arguments {
  my ($is_cached, $is_force, @arguments) = @_;
  my $show_usage = 0;
  my $arg;
  # Options at the start
  if($#arguments >= 0 && $arguments[0] =~ /^-/) {
    $arg = shift(@arguments);
    if($arg eq "--cached") {
      $is_cached = 1;
    } elsif($arg eq "--force") {
      $is_force = 1;
    } else {
      $show_usage = 1;
    }
  }
  # Options at the end
  if($#arguments >= 0 && $arguments[$#arguments] =~ /^-/) {
    $arg = pop(@arguments);
    if($arg eq "--cached") {
      $is_cached = 1;
    } elsif($arg eq "--force") {
      $is_force = 1;
    } else {
      $show_usage = 1;
    }
  }
  
  if( ! defined $arg) {
    foreach my $remainder (@arguments) {
      if($remainder =~ /^-/) {
        $show_usage = 1;
      }
    }
  }
  
  if($show_usage) {
    print STDERR "usage: $script_name rm [--force] [--cached] <filenames>\n";
    exit 1;
  }
  
  if(defined $arg) {
    ($is_cached, $is_force, @arguments) = ::get_rm_arguments($is_cached, $is_force, @arguments);
  } else {
    return ($is_cached, $is_force, @arguments);
  }
}

sub rm_command {
  Legit_Helpers::check_init();
  Legit_Helpers::check_commits();
  
  # Figure out which command line options used if any
  # Its recursive because for some reason having multiple of each option at the start or end is valid
  my ($is_cached, $is_force, @all_files) = ::get_rm_arguments(0, 0, @ARGV);
  
  # Load index into a hash
  my ($commit_num, $prev_num, %index) = Legit_Helpers::load_index();
  
  # Get the previous commit structure if there was one, for comparison
  #my $prev_num = $commit_num - 1;
  my %prev_commit = Legit_Helpers::load_commit_struct($prev_num);
  
  # Go through each file provided and check if its a valid file, and if not using --force option then check for differences
  foreach my $file (@all_files) {
    Legit_Helpers::validate_filename($file);
    
    if( ! defined $index{$file} || ($index{$file} ne "index" && $index{$file} < 0)) {
      print STDERR "$script_name: error: '$file' is not in the legit repository\n";
      exit 1;
    }
    if($is_force == 0) {
      my $current_loc = $index{$file} eq "index" ? $commit_num : $index{$file};
      # Compare index file with previous commit
      my $changed_prev_commit = defined $prev_commit{$file} ? compare("$commit_files_dir/$prev_commit{$file}/$file", "$commit_files_dir/$current_loc/$file") : -2;
      # Compare index file with current directory
      my $changed_cur_dir = compare($file, "$commit_files_dir/$current_loc/$file");
      
      if($changed_prev_commit != -2 && $changed_prev_commit != 0 && $changed_cur_dir != 0) {
        print "$changed_prev_commit $changed_cur_dir\n" if $file eq "f";
        print STDERR "$script_name: error: '$file' in index is different to both working file and repository\n";
        exit 1;
      } elsif($changed_prev_commit == 0 && $changed_cur_dir != 0 && $is_cached == 0) {
        print STDERR "$script_name: error: '$file' in repository is different to working file\n";
        exit 1;
      } elsif($changed_prev_commit != 0 && $changed_cur_dir == 0 && $is_cached == 0) {
        print STDERR "$script_name: error: '$file' has changes staged in the index\n";
        exit 1;
      }
    }
  }
  
  # Validation has passed so can now remove files
  foreach my $file (@all_files) {
    if($is_cached == 0) {
      unlink $file;
    }
    unlink "$commit_files_dir/$commit_num/$file";
    if(defined $index{$file}) {
      if($index{$file} eq "index") {
        delete $index{$file};
      } else {
        $index{$file} = -2;
      }
    }
  }
  Legit_Helpers::save_index(%index);
}

