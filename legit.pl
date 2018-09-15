#!/usr/bin/perl -w

use File::Copy;

# Setup a script name without ./
$script_name = $0;
$script_name =~ s/\.\///;
# Location of files
$index_loc = ".legit/index";
#$commit_loc = ".legit/commits";
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
  ::add_command();
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
      @{$index{$file}} = (0, -1);
    }
    @{$index{$file}}[0] = $commit_num;
  }
  
  # Write the hash to index
  open $f, ">", $index_loc or (print STDERR "$script_name: error: no .legit directory containing legit repository exists\n" and exit 1);
  print $f "$commit_num\n";
  foreach my $line (keys %index) {
    my $col_2 = @{$index{$line}}[0];
    my $col_3 = @{$index{$line}}[1];
    print $f "$line:$col_2:$col_3\n";
  }
  close $f;
}

sub commit_command {
  # Check if index and commits files exist
  
  # Check if correct arguments were provided
  
  # Load current index into hash
  my ($commit_num, %index) = ::load_index();
  
  # Iterate through index files, if file has been added and exists and has changed then copy into new directory
  
  # Add message to commits
}

