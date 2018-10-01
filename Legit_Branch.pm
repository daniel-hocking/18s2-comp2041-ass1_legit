package Legit_Branch;

use Legit_Helpers;
use base 'Exporter';
our @EXPORT = qw/branch_command checkout_command/;

$script_name = "legit.pl";

sub branch_command {
  Legit_Helpers::check_init();
  Legit_Helpers::check_commits();
  
  # Check all variations of arguments entered are valid
  if($#ARGV > 1 || ($#ARGV == 0 && $ARGV[0] =~ /^-/ && $ARGV[0] ne '-d') ||
    ($#ARGV == 1 && !($ARGV[0] eq '-d' && (length($ARGV[1]) == 0 ||$ARGV[1] =~ /^[^\-]/)) && 
    !($ARGV[1] eq '-d' && (length($ARGV[0]) == 0 ||$ARGV[0] =~ /^[^\-]/)))) {
    print STDERR "usage: $script_name branch [-d] <branch>\n";
    exit 1;
  }
  if($#ARGV == 0 && $ARGV[0] eq '-d') {
    print STDERR "$script_name: error: branch name required\n";
    exit 1;
  }

  my %commit_meta = Legit_Helpers::load_commit_meta();
  # If no arguments then show branches
  if($#ARGV == -1) {
    foreach $branch (sort values %{$commit_meta{"branches"}}) {
      print "$branch\n";
    }
  } else {
    my $branch_name = $ARGV[0];
    if($ARGV[0] eq '-d') {
      $branch_name = $ARGV[1];
    }
    if(!Legit_Helpers::validate_filename($branch_name, 1)) {
      print STDERR "$script_name: error: invalid branch name '$branch_name'\n";
      exit 1;
    }

    # One argument means create a branch
    if($#ARGV == 0) {
      if(! defined $commit_meta{"branches"}{$branch_name}) {
        my $current_branch = $commit_meta{"current_branch"};
        $commit_meta{"branches"}{$branch_name} = $branch_name;
        $commit_meta{"commits"}{$branch_name} = $commit_meta{"commits"}{$current_branch};
        Legit_Helpers::save_commit_meta(%commit_meta);
      } else {
        print STDERR "$script_name: error: branch '$branch_name' already exists\n";
        exit 1;
      }
    # Two arguments means delete a branch
    } else {
      # Can't delete the master branch
      if($branch_name eq "master") {
        print STDERR "$script_name: error: can not delete branch 'master'\n";
        exit 1;
      }
      
      # Check that there arent changes that would be lost if deleting branch
      
      if(defined $commit_meta{"branches"}{$branch_name}) {
        delete $commit_meta{"branches"}{$branch_name};
        Legit_Helpers::save_commit_meta(%commit_meta);
        print "Deleted branch '$branch_name'\n";
      } else {
        print STDERR "$script_name: error: branch '$branch_name' does not exist\n";
        exit 1;
      }
    }
  }
}

sub checkout_command {
  Legit_Helpers::check_init();
  Legit_Helpers::check_commits();
  
  if($#ARGV != 0 || $ARGV[0] =~ /^-/) {
    print STDERR "usage: $script_name checkout <branch>\n";
    exit 1;
  }
  
  my $branch_name = $ARGV[0];
  my %commit_meta = Legit_Helpers::load_commit_meta();
  my $current_branch = $commit_meta{"current_branch"};
  
  if($current_branch eq $branch_name) {
    print STDERR "Already on '$branch_name'\n";
    exit 1;
  }
  if(! defined $commit_meta{"branches"}{$branch_name}) {
    print STDERR "$script_name: error: unknown branch '$branch_name'\n";
    exit 1;
  }
}

# necessary
1;