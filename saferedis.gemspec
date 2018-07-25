Gem::Specification.new do |s|
  s.name = %q{saferedis}
  s.version = "0.0.1"
  s.date = %q{2018-07-24}
  s.license = "MIT"

  s.summary = %q{Connect to Redis without it being a point of failure}
  s.description = <<-EOS
  An add on for the redis-rb gem connector that keeps your site running when redis is down.
  EOS

  s.files = [
    "lib/saferedis.rb"
  ]
  s.require_paths = ["lib"]

  s.authors = [
    "Christos Christoudias",
  ]
end