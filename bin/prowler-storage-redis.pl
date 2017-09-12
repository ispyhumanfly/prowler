BEGIN {

    die "You must set the PROWLER_ROOT variable."
      unless exists $ENV{PROWLER_ROOT};
}
