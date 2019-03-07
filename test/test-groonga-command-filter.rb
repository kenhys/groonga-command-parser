# Copyright (C) 2019 Kentaro Hayashi <hayashi@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require "groonga/command/parser/command/groonga-command-filter"

class GroongaCommandFilterTest < Test::Unit::TestCase

  def fixture_path(*components)
    File.join(File.dirname(__FILE__), "fixtures", *components)
  end

  def test_dynamic_index
    output = StringIO.new
    @filter = Groonga::Command::Parser::Command::GroongaCommandFilter.new(output)
    @filter.run([
                  fixture_path(["blog_title.grn"]),
                  "--create-dynamic-index"
                ])
    expected =  <<-OUTPUT
table_create --flags "TABLE_HASH_KEY" --key_type "ShortText" --name "Site"
column_create --flags "COLUMN_SCALAR" --name "title" --table "Site" --type "ShortText"
table_create --default_tokenizer "TokenBigram" --flags "TABLE_PAT_KEY" --key_type "ShortText" --name "Terms" --normalizer "NormalizerAuto"
column_create --flags "COLUMN_INDEX|WITH_POSITION" --name "blog_title" --source "title" --table "Terms" --type "Site"
load --table "Site"
[
["_key","title"],
["http://example.org/","This is test record 1!"],
["http://example.net/","test record 2."],
["http://example.com/","test test record three."]
]
    OUTPUT
    assert_equal(expected, output.string)
  end
end
