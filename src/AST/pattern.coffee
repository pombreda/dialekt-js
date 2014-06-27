AbstractExpression = require './abstractExpression'
#
# An AST node that represents a pattern-match expression.
#
class Pattern extends AbstractExpression

  #
  # @param PatternChildInterface patterns[],... One or more pattern literals or placeholders.
  #
  constructor: (patterns...) ->
    @children = patterns

  #
  # @param PatternChildInterface $child The child to add.
  # 
  add: (patternChildInterface) ->
    @children.push patternChildInterface

  # Pass this node to the appropriate method on the given visitor.
  #
  # @param VisitorInterface visitor The visitor to dispatch to.
  # @return mixed The visitation result.
  #
  accept: (visitor) ->
    visitor.visitPattern(@)

module.exports = Pattern

