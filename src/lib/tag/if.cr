# The `if` tag is a conditional statement. The block content will only be evaluated if the test
# condition is truthy. Condition can be an arbitrary `Expression`. `elif` and `else` allow for
# multiple branches.
#
# ```
# {% if kenny.sick %}
#   Kenny is sick.
# {% elif kenny.dead %}
#   You killed Kenny!  You bastard!!!
# {% else %}
#   Kenny looks okay --- so far
# {% endif %}
# ```
#
# See [Jinja2 Template Documentation](http://jinja.pocoo.org/docs/2.9/templates/#if) for details.
class Crinja::Tag::If < Crinja::Tag
  name "if", "endif"

  # The taken branch's outputs as a list, which the enclosing list
  # writes out once, instead of a String built here and copied again
  # by every enclosing tag
  def interpret_output(renderer : Renderer, tag_node : TagNode)
    env = renderer.env
    output = Renderer::OutputList.new
    current_branch_active = evaluate_node(tag_node, env)

    tag_node.block.children.each do |node|
      if (tnode = node).is_a?(TagNode) && (tnode.name == "elif" || tnode.name == "else")
        break if current_branch_active

        current_branch_active = evaluate_node(tnode, env)
      else
        output << renderer.render(node) if current_branch_active
      end
    end
    output
  end

  private def interpret(io : IO, renderer : Crinja::Renderer, tag_node : TagNode)
    interpret_output(renderer, tag_node).value(io)
  end

  def evaluate_node(tag_node, env : Crinja)
    if tag_node.name == "else"
      return true
    end

    # The condition is the same on every render: parse it once
    expression = tag_node.parsed_condition ||= begin
      arguments = ArgumentsParser.new(tag_node.arguments, env.config)
      parsed = arguments.parse_expression

      if parsed.is_a?(AST::Empty)
        raise TemplateSyntaxError.new(tag_node, "#{tag_node.name} tag missing condition")
      end

      arguments.close
      parsed
    end

    value = env.evaluator.value(expression)
    value.truthy?
  end
end

class Crinja::Tag::If::Else < Crinja::Tag
  name "else"

  # Do nothing, interpretation is implemented by `If#interpret`.
  def interpret(io : IO, renderer : Crinja::Renderer, tag_node : TagNode)
  end
end

class Crinja::Tag::If::Elif < Crinja::Tag
  name "elif"

  # Do nothing, interpretation is implemented by `If#interpret`.
  def interpret(io : IO, renderer : Crinja::Renderer, tag_node : TagNode)
  end
end
