#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "yaml"

REQUIRED_FRONT_MATTER = %w[layout title date author header-img catalog tags].freeze

def read_front_matter(content)
  match = content.match(/\A---\n(.*?)\n---\n/m)
  return {} unless match

  YAML.safe_load(match[1], permitted_classes: [Date], aliases: true) || {}
end

def normalized_date(value)
  parts = value.to_s.split("-")
  return value unless parts.length == 3

  [parts[0], parts[1].rjust(2, "0"), parts[2].rjust(2, "0")].join("-")
end

def file_date(path)
  name = File.basename(path)
  match = name.match(/\A(\d{4})-(\d{1,2})-(\d{1,2})-/)
  return nil unless match

  [match[1], match[2].rjust(2, "0"), match[3].rjust(2, "0")].join("-")
end

issues = []

Dir["_posts/*.md"].sort.each do |path|
  content = File.read(path)
  front_matter = read_front_matter(content)

  missing = REQUIRED_FRONT_MATTER.reject { |key| front_matter.key?(key) }
  issues << [path, "missing front matter: #{missing.join(', ')}"] unless missing.empty?

  if (expected_date = file_date(path)) && front_matter["date"]
    actual_date = normalized_date(front_matter["date"])
    if expected_date != actual_date
      issues << [path, "date mismatch: filename=#{expected_date}, front_matter=#{actual_date}"]
    end
  end

  if File.basename(path).match?(/\s+\.md$/) || File.basename(path).match?(/\s/)
    issues << [path, "filename contains spaces; review permalink impact before renaming"]
  end

  external_markdown_images = content.scan(/!\[[^\]]*\]\((https?:\/\/[^)]+)\)/i).flatten
  external_html_images = content.scan(/<img[^>]+src=["'](https?:\/\/[^"']+)["']/i).flatten
  external_image_count = (external_markdown_images + external_html_images).uniq.size
  issues << [path, "external images: #{external_image_count}"] if external_image_count.positive?

  empty_alt_count = content.scan(/!\[\]\(/).size
  issues << [path, "empty image alt text: #{empty_alt_count}"] if empty_alt_count.positive?

  raw_img_count = content.scan(/<img\b/i).size
  issues << [path, "raw HTML images: #{raw_img_count}"] if raw_img_count.positive?
end

if issues.empty?
  puts "No content issues found."
  exit 0
end

issues.each do |path, message|
  puts "#{path}: #{message}"
end
