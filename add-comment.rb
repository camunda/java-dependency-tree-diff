#!/usr/bin/env ruby

require "json"
require "octokit"

github = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

event = JSON.parse(File.read(ENV.fetch("GITHUB_EVENT_PATH")))
repo = event["repository"]["full_name"]
pr_number = event["number"]

github.issue_comments(repo, pr_number)

if ARGV.length == 1
	message = File.read(ARGV[0])
else
	message = "Unchanged Java Dependency Tree"
end

github.add_comment(repo, pr_number, message)