#!/usr/bin/perl -w

use File::Copy;
use File::Compare;

# Setup a script name without ./
$script_name = $0;
$script_name =~ s/\.\///;
# Location of files
$index_loc = ".legit/index";
$commit_loc = ".legit/commits";
# If no arguments then show usage and exit
if($#ARGV == -1) {
  ::show_usage();
}
# If first argument doesnt match valid command then show usage and exit
my $cmd = shift @ARGV;
if(::valid_commands($cmd) == 0) {
  ::show_usage();
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

sub show_usage {
  print STDERR "Usage: legit.pl <command> [<args>]

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
  );
  return defined $commands{$cmd} ? $commands{$cmd} : 0;
}

sub load_index {
  open my $f, "<", $index_loc or (print STDERR "$script_name: error: no .legit directory containing legit repository exists\n" and exit 1);
  my @index_lines = <$f>;
  close $f;
  my $commit_num = shift @index_lines;
  chomp $commit_num;
  my %index = ();
  foreach my $line (@index_lines) {
    chomp $line;
    if($line =~ /(.+):(.+):(.+)/) {
      @{$index{$1}} = ($2, $3);
    }
  }
  return ($commit_num, %index);
}

sub save_index {
  my ($commit_num, %index) = @_;
  
  open my $f, ">", $index_loc or (print STDERR "$script_name: error: no .legit directory containing legit repository exists\n" and exit 1);
  print $f "$commit_num\n";
  foreach my $line (keys %index) {
    my $col_2 = @{$index{$line}}[0];
    my $col_3 = @{$index{$line}}[1];
    print $f "$line:$col_2:$col_3\n";
  }
  close $f;
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
  open my $f, ">", "$init_dir/index" or (print STDERR "$script_name: error: could not create legit depository\n" and exit 1);
  print $f "0";
  close $f;
  open $f, ">", "$init_dir/commits" or (print STDERR "$script_name: error: could not create legit depository\n" and exit 1);
  print $f "";
  close $f;
  print "Initialized empty legit repository in $init_dir\n";
}

sub add_command {
  # Check if have init'd yet
  if( ! -f $index_loc) {
    print STDERR "$script_name: error: no .legit directory containing legit repository exists\n";
    exit 1;
  }
  
  # Check at least one file to add
  if($#ARGV < 0) {
    print STDERR "$script_name: error: internal error Nothing specified, nothing added.
Maybe you wanted to say 'git add .'?

You are not required to detect this error or produce this error message.\n";
    exit 1;
  }
  
  # Load current index into hash
  my ($commit_num, %index) = ::load_index();
  
  # Check if all files valid
  # Add new files to hash (this will remove dupes)
  foreach my $file (@ARGV) {
    # Check file has invalid chars
    if(!($file =~ /^[a-z0-9]/i && $file =~ /^[a-z0-9\-_\.]+$/i)) {
      print STDERR "$script_name: error: invalid filename '$file'\n";
      exit 1;
    }
    # Check if the file exists
    if( ! -f $file) {
      print STDERR "$script_name: error: can not open '$file'\n";
      exit 1;
    }
    
    if(! defined $index{$file}) {
      @{$index{$file}} = ($commit_num, -1);
    }
    @{$index{$file}}[0] = $commit_num;
  }
  
  # Write the hash to index, also copy files into staging area
  ::save_index($commit_num, %index);
  my $legit_dir = ".legit";
  my $commit_dir = "$legit_dir/$commit_num";
  if( ! -d $commit_dir) {
    mkdir $commit_dir or (print STDERR "$script_name: error: could not create commit folder\n" and exit 1);
  }
  foreach my $line (keys %index) {
    if(@{$index{$line}}[0] == $commit_num) {
      my $prev_commit = @{$index{$line}}[1];
      if($prev_commit == -1 || compare($line, "$legit_dir/$prev_commit/$line") != 0) {
        copy $line, "$commit_dir/$line";
      }
    }
  }
}

sub commit_command {
  # Check if index and commits files exist
  if( ! -f $index_loc) {
    print STDERR "$script_name: error: no .legit directory containing legit repository exists\n";
    exit 1;
  }
  
  # Check if correct arguments were provided
  if($#ARGV != 1 || $ARGV[0] ne '-m' && $ARGV[1] =~ /^[^-]/) {
    print STDERR "usage: $script_name commit [-a] -m commit-message\n";
    exit 1;
  }
  
  # Load current index into hash
  my ($commit_num, %index) = ::load_index();
  my $commit_dir = ".legit/$commit_num";
  my $changes_made = 0;
  # Iterate through index files, if file has been added and has changed then commit
  foreach my $file (keys %index) {
    if(@{$index{$file}}[0] == $commit_num && -f "$commit_dir/$file") {
      @{$index{$file}}[1] = $commit_num;
      $changes_made = 1;
    }
  }
  
  if($changes_made == 1) {
    # Add message to commits
    my $commit_message = $ARGV[1];
    open my $f, ">>", $commit_loc or (print STDERR "$script_name: error: could not open commits file to save commit message\n" and exit 1);
    print $f "$commit_num $commit_message\n";
    close $f;
    
    print "Committed as commit $commit_num\n";
    # Update index
    $commit_num++;
    ::save_index($commit_num, %index);
  } else {
    print "Nothing to commit\n";
  }
}

sub log_command {
  # Check have init'd repository
  if( ! -f $index_loc) {
    print STDERR "$script_name: error: no .legit directory containing legit repository exists\n";
    exit 1;
  }
  
  open my $f, "<", $commit_loc or (print STDERR "$script_name: error: could not open commits file to show commit message\n" and exit 1);
  my @lines = <$f>;
  foreach my $line (reverse @lines) {
    chomp $line;
    if($line) {
      print "$line\n";
    }
  }
  close $f;
}

