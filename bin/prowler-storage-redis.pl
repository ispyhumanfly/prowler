BEGIN {

    die "You must set the PROWLER_ROOT envivironment variable."
      unless exists $ENV{PROWLER_ROOT};
}
