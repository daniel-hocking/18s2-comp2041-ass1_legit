package Legit_Helpers;

use JSON;
use List::Util;
use base 'Exporter';
our @EXPORT = qw/check_init check_commits load_json_file save_json_file load_commit_meta save_commit_meta add_commit_message get_commit_num load_commit_struct save_commit_struct load_index save_index commit_to_index validate_filename update_current_branch update_index_on_checkout/;

$script_name = "legit.pl";
$commit_loc = ".legit/commit_meta";
$struct_loc = ".legit/commit_struct";

sub check_init {
  if( ! -f $commit_loc) {
    print STDERR "$script_name: error: no .legit directory containing legit repository exists\n";
    exit 1;
  }
}

sub check_commits {
  my ($commit_num, $prev_commit) = Legit_Helpers::get_commit_num();
  if($commit_num == 0) {
    print STDERR "$script_name: error: your repository does not have any commits yet\n";
    exit 1;
  }
  return $commit_num;
}

sub load_json_file {
  my ($location) = @_;
  open my $f, "<", $location or (print STDERR "$script_name: error: could not open $location file to load json\n" and exit 1);
  my $json_str = <$f>;
  close $f;
  if(defined $json_str) {
    my $hash_data = decode_json $json_str;
    return %{$hash_data};
  } else {
    return ();
  }
}

sub save_json_file {
  my ($location, %hash_data) = @_;
  open my $f, ">", $location or (print STDERR "$script_name: error: could not open $location file to save json\n" and exit 1);
  print $f encode_json \%hash_data;
  close $f;
}

sub load_commit_meta {
  return ::load_json_file($commit_loc);
}

sub save_commit_meta {
  my (%commit_meta) = @_;
  ::save_json_file($commit_loc, %commit_meta);
}

sub add_commit_message {
  my ($message) = @_;
  my %commit_meta = ::load_commit_meta();
  my $commit_num = $commit_meta{"current_commit"};
  my $current_branch = $commit_meta{"current_branch"};
  $commit_meta{"current_commit"} = $commit_num + 1;
  $commit_meta{"commits"}{$current_branch}{$commit_num} = $message;
  ::save_commit_meta(%commit_meta);
}

sub update_current_branch {
  my ($branch) = @_;
  my %commit_meta = ::load_commit_meta();
  $commit_meta{"current_branch"} = $branch;
  ::save_commit_meta(%commit_meta);
}

sub get_commit_num {
  my %commit_meta = ::load_commit_meta();
  my $current_branch = $commit_meta{"current_branch"};
  my $prev_commit = List::Util::max(keys(%{$commit_meta{"commits"}{$current_branch}}));
  return ($commit_meta{"current_commit"}, $prev_commit);
}

sub load_commit_struct {
  my ($commit_num) = @_;
  return ::load_json_file("$struct_loc/$commit_num");
}

sub save_commit_struct {
  my ($commit_num, %commit_struct) = @_;
  ::save_json_file("$struct_loc/$commit_num", %commit_struct);
}

sub load_index {
  my ($commit_num, $prev_commit) = ::get_commit_num();
  my %commit_struct = ::load_commit_struct("index");
  return ($commit_num, $prev_commit, %commit_struct);
}

sub save_index {
  my (%index) = @_;
  ::save_commit_struct("index", %index);
}

sub commit_to_index {
  my ($commit_num) = @_;
  my %commit_struct = ::load_commit_struct($commit_num);
  foreach my $file (keys %commit_struct) {
    if($commit_struct{$file} < 0) {
      delete $commit_struct{$file};
    }
  }
  ::save_index(%commit_struct);
}

sub update_index_on_checkout {
  my (%prev_commit) = @_;
  my ($commit_num, $prev_commit, %commit_struct) = ::load_index();
  foreach my $index_file (keys %commit_struct) {
    if($commit_struct{$index_file} eq "index" && ! defined $prev_commit{$index_file}) {
      $prev_commit{$index_file} = "index";
    } elsif($commit_struct{$index_file} == $commit_num && defined $prev_commit{$index_file}) {
      $prev_commit{$index_file} = $commit_num;
    }
  }
  ::save_index(%prev_commit);
}

sub validate_filename {
  my ($file, $just_return) = @_;
  
  if(!($file =~ /^[a-z0-9]/i && $file =~ /^[a-z0-9\-_\.]+$/i)) {
    if(! defined $just_return) {
      print STDERR "$script_name: error: invalid filename '$file'\n";
      exit 1;
    } else {
      return 0;
    }
  }
  return 1;
}

# necessary
1;