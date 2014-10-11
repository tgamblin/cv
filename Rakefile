# -*- ruby -*-

require 'Set'

# Location of my webpage repo and relevant files in it.
web_repo = '/Users/gamblin2/Sites/tgamblin.github.io'

# Recursively get all dependences of a tex file, return them as a set of file names.
def get_deps(texfile, deps = Set.new([texfile]))
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

  unless get_deps(texfile).map { |file| uptodate?(pdffile, [file]) }.all?
    system("pdflatex #{texfile}")
  end

  newcites = File.open(texfile).grep(/newcites/).first
  bibnamestring = newcites.scan(/\{(\w+(,\w+)*)\}/).map {|x| x[0]}.first
  bibnames = bibnamestring.split(',')

  bibfiles = bibnames.map do |name|
    File.open(texfile).grep(/\\bibliography#{name}\{(.*)\}/) do |file|
      "#{$1}.bib"
    end.first
  end

  bibbed = false
  bibnames.zip(bibfiles).each do |name, bibfile|
    bblfile = "#{name}.bbl"
    unless uptodate?(bblfile, [bibfile]) and uptodate?(pdffile, [bblfile])
      system("bibtex #{name}")
      bibbed = true
    end
  end

  if (bibbed)
    system("pdflatex #{texfile}")
    system("pdflatex #{texfile}")
  end
end

# === Tasks ===============================
task :default => :cv

# --- CV targets --------------------------
task :cv do
  build_pdf("todd-cv")
end

task :grant do
  build_pdf("grant-cv")
end

task :ldrd do
  build_pdf("ldrd-cv")
end

# --- Generate html for bibliography ----------
task :html do
  Dir.chdir("Bibliographies") do
    system("./generate_html.sh")
  end
end

# --- Upload to webpage -----------------------
task :upload => :cv do
  # Locations in the web repo
  cv   = "cv/todd-cv.pdf"
  html = "_includes/bibliography.html"

  cp "Bibliographies/bibliography.html", "#{web_repo}/#{html}"
  cp "todd-cv.pdf", "#{web_repo}/#{cv}"

  Dir.chdir("#{web_repo}") do
    system("git add #{cv}")
    system("git add #{html}")
    system("git commit -m 'CV update'")
    system("git push")
  end
end

# --- Cleanup -----------------------------
task :clean do
  files = ["todd-cv.pdf", "grant-cv.pdf"]
  files.unshift Dir.glob(%w(*.aux *.bbl *.blg *.log *.out *synctex.gz*))
	FileUtils.rm_f(files)
end
