require "../src/crinja"
require "benchmark"

BASE = Crinja.new

SIMPLE_SOURCE = <<-'TPL'
Hello {{ name }}! You are {{ user.age }} years old.
{% if admin %}Admin{% else %}User{% endif %}
TPL

LOOPS_SOURCE = <<-'TPL'
<ul>
{%- for item in items %}
  <li>{{ loop.index }}: {{ item.name }} costs {{ item.price | round(2) }}</li>
{%- endfor %}
</ul>
Total: {{ items | map(attribute='price') | sum }}
Count: {{ items | length }}
Names sorted: {{ items | map(attribute='name') | sort | join(', ') }}
TPL

EXPRESSIONS_SOURCE = <<-'TPL'
{{ a + b * 2 }}
{{ a > b and b > c }}
{% if a is equalto(10) %}yes{% else %}no{% endif %}
{{ user.name | upper }} / {{ user['name'] | lower }}
{{ missing | default('fallback') }}
{{ "%d items" | format(100) }}
TPL

MACROS_SOURCE = <<-'TPL'
{% macro input(name, value='', type='text') -%}
<input type="{{ type }}" name="{{ name }}" value="{{ value }}">
{%- endmacro %}
{{ input('username') }}
{{ input('age', type='number') }}
{% for i in range(3) %}{{ i }}{% endfor %}
{% set x = 42 %}{{ x + 1 }}
TPL

@[Crinja::Attributes(expose: [name, price])]
class Item
  include Crinja::Object::Auto

  property name : String
  property price : Float64

  def initialize(@name : String, @price : Float64); end
end

ITEMS = (1..100).map { |i| Item.new("item #{i}", i.to_f * 1.5) }.to_a

def bindings
  {
    "name"  => "World",
    "admin" => true,
    "user"  => {"name" => "alice", "age" => 33},
    "items" => ITEMS,
    "a"     => 10,
    "b"     => 4,
    "c"     => 2,
  }
end

SIMPLE       = BASE.from_string(SIMPLE_SOURCE)
LOOPS        = BASE.from_string(LOOPS_SOURCE)
EXPRESSIONS  = BASE.from_string(EXPRESSIONS_SOURCE)
MACROS_TPL   = BASE.from_string(MACROS_SOURCE)

# sanity check + warmup
10.times do
  SIMPLE.render(bindings)
  LOOPS.render(bindings)
  EXPRESSIONS.render(bindings)
  MACROS_TPL.render(bindings)
end

puts "== Render (pre-parsed templates) =="
Benchmark.ips do |benchmark|
  benchmark.report("render simple")     { SIMPLE.render(bindings) }
  benchmark.report("render loops")      { LOOPS.render(bindings) }
  benchmark.report("render expressions") { EXPRESSIONS.render(bindings) }
  benchmark.report("render macros")     { MACROS_TPL.render(bindings) }
end

puts "\n== Parse + compile =="
Benchmark.ips do |benchmark|
  benchmark.report("parse simple") { BASE.from_string(SIMPLE_SOURCE) }
  benchmark.report("parse loops")  { BASE.from_string(LOOPS_SOURCE) }
end
