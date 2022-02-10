Gem::Specification.new do |spec|
  spec.name          = "oppen"
  spec.version       = "0.0.1"
  spec.authors       = ["Firas al-Khalil"]
  spec.email         = ["firasalkhalil@gmail.com"]

  spec.summary       = %q{Oppen's pretty printer.}
  spec.description   = %Q{An API to pretty-print structures.\nUsually used to pretty-print ASTs into source code.}
  spec.homepage      = "https://github.com/stackmystack/oppen-rb"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0")
  spec.licenses      = ["MIT"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
