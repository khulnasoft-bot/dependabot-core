# frozen_string_literal: true

require "octokit"
require "gitlab"
require "spec_helper"
require "dependabot/dependency"
require "dependabot/metadata_finders/base"

RSpec.describe Dependabot::MetadataFinders::Base do
  subject(:finder) do
    described_class.new(dependency: dependency, github_client: github_client)
  end
  let(:dependency) do
    Dependabot::Dependency.new(
      name: dependency_name,
      version: dependency_version,
      requirements: [
        { file: "Gemfile", requirement: ">= 0", groups: [], source: nil }
      ],
      previous_requirements: [
        { file: "Gemfile", requirement: ">= 0", groups: [], source: nil }
      ],
      previous_version: dependency_previous_version,
      package_manager: "bundler"
    )
  end
  let(:dependency_name) { "business" }
  let(:dependency_version) { "1.4.0" }
  let(:dependency_previous_version) { "1.0.0" }
  let(:github_client) { Octokit::Client.new(access_token: "token") }
  before do
    allow(finder).
      to receive(:source).
      and_return("host" => "github", "repo" => "gocardless/#{dependency_name}")
  end

  describe "#source_url" do
    subject { finder.source_url }

    it { is_expected.to eq("https://github.com/gocardless/business") }

    context "with a bitbucket source" do
      before do
        allow(finder).
          to receive(:source).
          and_return("host" => "bitbucket", "repo" => "org/#{dependency_name}")
      end

      it { is_expected.to eq("https://bitbucket.org/org/business") }
    end

    context "without a source" do
      before { allow(finder).to receive(:source).and_return(nil) }
      it { is_expected.to be_nil }
    end
  end

  describe "#commits_url" do
    subject { finder.commits_url }
    let(:dummy_commits_url_finder) do
      instance_double(Dependabot::MetadataFinders::Base::CommitsUrlFinder)
    end

    it "delegates to CommitsUrlFinder (and caches the instance)" do
      expected_source =
        { "host" => "github", "repo" => "gocardless/#{dependency_name}" }
      expect(Dependabot::MetadataFinders::Base::CommitsUrlFinder).
        to receive(:new).
        with(
          github_client: github_client,
          source: expected_source,
          dependency: dependency
        ).once.and_return(dummy_commits_url_finder)
      expect(dummy_commits_url_finder).
        to receive(:commits_url).twice.
        and_return("https://example.com/commits")
      expect(finder.commits_url).to eq("https://example.com/commits")
      expect(finder.commits_url).to eq("https://example.com/commits")
    end
  end

  describe "#changelog_url" do
    subject { finder.changelog_url }
    let(:dummy_changelog_finder) do
      instance_double(Dependabot::MetadataFinders::Base::ChangelogFinder)
    end

    it "delegates to ChangelogFinder (and caches the instance)" do
      expected_source =
        { "host" => "github", "repo" => "gocardless/#{dependency_name}" }
      expect(Dependabot::MetadataFinders::Base::ChangelogFinder).
        to receive(:new).
        with(
          github_client: github_client,
          source: expected_source,
          dependency: dependency
        ).once.and_return(dummy_changelog_finder)
      expect(dummy_changelog_finder).
        to receive(:changelog_url).twice.
        and_return("https://example.com/CHANGELOG.md")
      expect(finder.changelog_url).to eq("https://example.com/CHANGELOG.md")
      expect(finder.changelog_url).to eq("https://example.com/CHANGELOG.md")
    end
  end

  describe "#release_url" do
    subject { finder.release_url }
    let(:dummy_release_finder) do
      instance_double(Dependabot::MetadataFinders::Base::ReleaseFinder)
    end

    it "delegates to ReleaseFinder (and caches the instance)" do
      expected_source =
        { "host" => "github", "repo" => "gocardless/#{dependency_name}" }
      expect(Dependabot::MetadataFinders::Base::ReleaseFinder).
        to receive(:new).
        with(
          github_client: github_client,
          source: expected_source,
          dependency: dependency
        ).once.and_return(dummy_release_finder)
      expect(dummy_release_finder).
        to receive(:release_url).twice.
        and_return("https://example.com/RELEASES.md")
      expect(finder.release_url).to eq("https://example.com/RELEASES.md")
      expect(finder.release_url).to eq("https://example.com/RELEASES.md")
    end
  end
end
