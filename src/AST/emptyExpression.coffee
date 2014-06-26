ExpressionInterface = require './expressionInterface'
#
# An AST node that represents an empty expression.
#
class EmptyExpression extends ExpressionInterface
  
  # Pass this node to the appropriate method on the given visitor.
  #
  # @param VisitorInterface visitor The visitor to dispatch to.
  # @return mixed The visitation result.
  #
  accept: (visitor) ->
    return visitor.visitEmptyExpression(@)


module.exports = EmptyExpression




