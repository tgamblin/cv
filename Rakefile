# -*- ruby -*-

require 'Set'
web_dest = 'snapper.cs.unc.edu:www/cv'

# Recursively get all dependences of a tex file, return them as a set of file names.
def get_deps(texfile, deps = Set.new(texfile))
  basenames = File.open(texfile).grep(/\\(include|input)\{([^}]+)\}/) { |x| $2 }
  depfiles = basenames.map do |name|
    if name =~ /\.tex$/ then name else name + ".tex" end
  end

  depfiles.each do |file|
    if not deps.member?(file)
      deps.add(file)
      get_deps(file, deps)
    end
  end

  return deps
end

# Get deps of a pdf and build it using pdflatex and bibtex
def build_pdf(name)
  texfile = "#{name}.tex"
  pdffile = "#{name}.pdf"

  unless get_deps(texfile).map { |file| FileUtils.uptodate?(pdffile, file) }.all?
    system("pdflatex #{texfile}")
  end

  newcites = File.open(texfile).grep(/newcites/).first
  bibnamestring = newcites.scan(/\{(\w+(,\w+)*)\}/).map {|x| x[0]}.first
  bibnames = bibnamestring.split(',')

  bibfiles = bibnames.map do |name|
    bibfiles = File.open(texfile).grep(/\\bibliography#{name}\{(.*)\}/) do |file|
      "#{$1}.bib"
    end
  end

  bibbed = false
  bibnames.zip(bibfiles).each do |name, bibfile|
    bblfile = "#{name}.bbl"
    unless uptodate?(bblfile, bibfile) and uptodate?(pdffile, bblfile)
      system("bibtex #{name}")
      bibbed = true
    end
  end

  if (bibbed)
    system("pdflatex #{texfile}")
    system("pdflatex #{texfile}")
  end
end

# various filename variables
name="todd-cv"
pdffile = "#{name}.pdf"
texfile = "#{name}.tex"

task :default => :cv

# Main cv target
task :cv do
  build_pdf(name)
end

task :upload => :cv do
  system("scp #{pdffile} #{web_dest}")
end

# Clean everything up
task :clean do
  files = [pdffile]
  files.unshift Dir.glob(%w(*.aux *.bbl *.blg *.log *.out *synctex.gz*))
	FileUtils.rm_f(files)
end
