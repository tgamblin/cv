#!/usr/bin/ruby

file, htmlfile = *ARGV

cmd = "pdftohtml -c -noframes #{file} #{htmlfile}"
if not system(cmd) 
  puts "Couldn't execute command: '#{cmd}'"
  exit
end

input = File.open(htmlfile)
text = input.read
input.close()

# Change fonts to Arial
text.gsub!(/font-family:Times/, "font-family:Arial")

# Strip stray periods if we find them
straydots = /(<\a>)?(<\/span><\/nobr><\/DIV>\s*\n<DIV style=[^>]+><nobr><span class=[^>]+>)(<A[^>]*>)?\./
text.gsub!(straydots) {"\.#{$1}#{$2}#{$3}"}

# Strip any empty links left behind by the stray periods
text.gsub!(/<A[^>]*>\s*<\a>/, "")

# Strip out outline at the end
text.gsub!(/<hr>\n<A name="outline"><\/a><h1>Document Outline<\/h1>[^\/]*\/ul>/, "")

# Fix up body background color
text.gsub!(/<BODY bgcolor="#A0A0A0"/, '<BODY bgcolor="#FFFFFF"')

# Fix up particularly egregious paper titles
oldtitle=/<DIV style="position:absolute;top:988;left:550"><nobr><span class="ft1028"><A href="http:\/\/www.cs.unc.edu\/~tgamblin\/pubs\/ampl-ipdps08.pdf">Scalable/
newtitle='<DIV style="position:absolute;top:988;left:500"><nobr><span class="ft1028"><A href="http://www.cs.unc.edu/~tgamblin/pubs/ampl-ipdps08.pdf">Scalable'
text.gsub!(oldtitle, newtitle)

oldtitle=/<DIV style="position:absolute;top:823;left:779"><nobr><span class="ft543"><A href="http:\/\/www.cs.unc.edu\/~tgamblin\/pubs\/wavelet-sc08.pdf">Scalable/
newtitle='<DIV style="position:absolute;top:823;left:679"><nobr><span class="ft543"><A href="http://www.cs.unc.edu/~tgamblin/pubs/wavelet-sc08.pdf">Scalable'
text.gsub!(oldtitle, newtitle)

oldtitle=/<DIV style="position:absolute;top:291;left:779"><nobr><span class="ft3">Scalable/
newtitle='<DIV style="position:absolute;top:291;left:679"><nobr><span class="ft3">Scalable'
text.gsub!(oldtitle, newtitle)


# Fix up publication subsections (this RE is kind of magical... might be brittle)
text.gsub!(/<i>. ([^\<]+) .<\/i>/) {"<i>&mdash; #{$1} &mdash;<\/i>"}

# Finally line up the name correctly
oldname = /<DIV style="position:absolute;top:84;left:486"><nobr><span class="ft0">Todd<\/span><\/nobr><\/DIV>\n<DIV style="position:absolute;top:84;left:601"><nobr><span class="ft1">Gamblin<\/span><\/nobr><\/DIV>/
newname = '<DIV style="position:absolute;top:64;left:466"><nobr><span class="ft0">Todd<\/span><\/nobr><\/DIV>\n<DIV style="position:absolute;top:64;left:585"><nobr><span class="ft1">Gamblin<\/span><\/nobr><\/DIV>'
text.gsub!(oldname, newname)

html_output = File.open(htmlfile, 'w')
html_output.write(text)
html_output.close()
