#!/usr/bin/perl -w

use File::Copy;
use File::Compare;

use Legit_Helpers;

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
  );
  Legit_Helpers::save_commit_meta(%commit_meta);
  print "Initialized empty legit repository in $init_dir\n";
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
  
  # Load current index into hash
  my ($commit_num, %index) = Legit_Helpers::load_index();
  
  # Check if all files valid
  # Add new files to hash (this will remove dupes)
  foreach my $file (@ARGV) {
    if($file =~ /^-/) {
      print STDERR "usage: $script_name add <filenames>\n";
      exit 1;
    }
    # Check file has invalid chars
    Legit_Helpers::validate_filename($file);
    if(! defined $index{$file}) {
      # Check if the file exists
      if( ! -f $file) {
        print STDERR "$script_name: error: can not open '$file'\n";
        exit 1;
      }
      $index{$file} = "index";
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
      }
    }
  }
  
  # Write the hash to index, also copy files into staging area
  my $prev_num = $commit_num - 1;
  my %prev_commit;
  %prev_commit = Legit_Helpers::load_commit_struct($prev_num) if $commit_num > 0;
  my $commit_dir = "$commit_files_dir/$commit_num";
  if( ! -d $commit_dir) {
    mkdir $commit_dir or (print STDERR "$script_name: error: could not create commit folder\n" and exit 1);
  }
  foreach my $file (keys %index) {
    if($index{$file} eq "index") {
      copy $file, "$commit_dir/$file";
    } elsif($index{$file} == $commit_num) {
      if(! defined $prev_commit{$file} || compare($file, "$commit_files_dir/$prev_commit{$file}/$file") != 0) {
        copy $file, "$commit_dir/$file";
      } else {
        $index{$file} = $prev_commit{$file};
        unlink "$commit_dir/$file";
      }
    } elsif($index{$file} == -1) {
      unlink "$commit_dir/$file";
    }
  }
  Legit_Helpers::save_index(%index);
}

sub commit_command {
  Legit_Helpers::check_init();
  
  # Check if correct arguments were provided
  if($#ARGV != 1 || $ARGV[0] ne '-m' || $ARGV[1] =~ /^-/) {
    print STDERR "usage: $script_name commit [-a] -m commit-message\n";
    exit 1;
  }
  
  # Load current index into hash
  my ($commit_num, %index) = Legit_Helpers::load_index();
  my $commit_dir = "$commit_files_dir/$commit_num";
  my $changes_made = 0;
  # Iterate through index files, if file has been added and has changed then commit
  foreach my $file (keys %index) {
    if($index{$file} eq "index") {
      $index{$file} = $commit_num;
      $changes_made = 1;
    } elsif($index{$file} == $commit_num && -f "$commit_dir/$file") {
      $changes_made = 1;
    } elsif($commit_num > 0 && $index{$file} == -1) {
      $changes_made = 1;
    }
  }

  if($changes_made == 1) {
    # Add message to commits
    Legit_Helpers::add_commit_message($ARGV[1]);
    
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
  
  my %commit_meta = Legit_Helpers::load_commit_meta();
  if(! defined $commit_meta{"commits"}) {
    print STDERR "$script_name: error: your repository does not have any commits yet\n";
    exit 1;
  }
  foreach my $commit_num (sort {$b <=> $a} keys %{$commit_meta{"commits"}}) {
    my $commit_message = $commit_meta{"commits"}{$commit_num}{"message"};
    print "$commit_num $commit_message\n";
  }
}

sub show_command {
  Legit_Helpers::check_init();
  
  my $commit_num = Legit_Helpers::get_commit_num();
  if($commit_num == 0) {
    print STDERR "$script_name: error: your repository does not have any commits yet\n";
    exit 1;
  }
  
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
      if($commit =~ /.*[^0-9].*/ || $commit < 0 || $commit > $commit_num) {
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
    if( ! defined $index{$filename} || ($index{$filename} ne "index" && $index{$filename} == -1)) {
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

