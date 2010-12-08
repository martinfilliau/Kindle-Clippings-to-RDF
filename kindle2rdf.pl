# Convert Kindle clippings in RDF
# Martin Filliau, 2010

use constant CLIPPING_SEPARATOR => '==========';
use constant CLIPPING_HIGHLIGHT => 'Highlight';
use constant CLIPPING_BOOKMARK => 'Bookmark';
use constant CLIPPING_NOTE => 'Note';
use constant URI_BEGIN => 'http://martin-kindle.com';	# no trailing slash

open FILE, $ARGV[0] or die "Give me the path of a file, please.";
binmode FILE;
$text = join("", <FILE>);
close FILE;

print qq~<rdf:RDF
	  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	  xmlns:dc="http://purl.org/dc/elements/1.1/"
	  xmlns:q="http://purl.org/quote/elements/0.1/">\n~;

my @quotes = split(/==========/, $text);

foreach my $quote (@quotes) {
	my $title = "";
	my $author = "";
	my $location = "";
	my $value = "";
	my $type = "";	# highlight, bookmark, note
	
	my @lines = split(/\n/, $quote);

	if ($lines[1] =~ "(.*)+? [(](.*)+?[)]") {
			$title = $1;
			$author = $2;
	}
	
	$title =~ s/\r|\n//g;	# removing potential return line
	$author =~ s/\r|\n//g;	# removing potential return line
	
	if ($lines[2] =~ "- (.+?) Loc. (.+?) | Added on (.+?), (.+?) (.+?), (.+?), (.+?) (.+?)") {
			$location = $2;
			$type = $1;
	}

	$value = $lines[4];
	$value =~ s/\r|\n//g;	# removing potential return line

	my $uri = URI_BEGIN . join('_', split ' ', "/${author}/${title}/${location}");
	
	if (length($value) > 1 && ($type eq CLIPPING_HIGHLIGHT || $type eq CLIPPING_NOTE)) {
		print "<q:quotation rdf:about=\"${uri}\">\n";
		print "	<dc:title>${title}<\/dc:title>\n";
		print "	<dc:creator>${author}<\/dc:creator>\n";
		print "	<q:location>${location}<\/q:location>\n";
		print "	<q:quote>${value}<\/q:quote>\n";
		print "	<q:type>${type}<\/q:type>\n";
		print "<\/q:quotation>\n";
	}
}

print "</rdf:RDF>\n";

