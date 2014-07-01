ParserInterface = require './parserInterface'
Token           = require './token'
Lexer           = require './lexer'

EmptyExpression = require '../AST/emptyExpression'

InterfaceException  = require '../Exception/interfaceException'
ParseException      = require '../Exception/parseException'

class AbstractParser extends ParserInterface

  #
  # @param LexerInterface|null lexer The lexer used to tokenise input expressions.
  #
  constructor: (lexer) -> 
    @lexer = lexer or new Lexer;

    @captureSourceOffsetStack = []

    @setWildcardString(Token.WILDCARD_CHARACTER)
    @setCaptureSource(false)

  #
  # Set the string to use as a wildcard placeholder.
  #
  # @param string wildcardString The string to use as a wildcard placeholder.
  #
  setWildcardString: (wildcardString) ->
    @wildcardString = wildcardString

  #
  # Set whether or not the parser captures the expression source for each AST
  # node.
  #
  # @param boolean captureSource True if expression source is captured; otherwise, false.
  #
  setCaptureSource: (captureSource) ->
    @captureSource = captureSource

  #
  # Parse an expression.
  #
  # @param string expression The expression to parse.
  #
  # @return ExpressionInterface The parsed expression.
  # @throws ParseException      if the expression is invalid.
  #
  parse: (expression) ->
    if @captureSource
      @captureSourceExpression = expression

    # This acts as our array iterator
    @currentTokenIndex = 0
    @tokens = @lexer.lex(expression)

    if not @tokens or @tokens.length is 0
      expression = new EmptyExpression
      if @captureSource
        expression.setSource @captureSourceExpression, 0

      return expression

    expression = @_parseExpression()

    if @tokens[@currentTokenIndex]
        throw new ParseException 'Unexpected ' + Token.typeDescription(@tokens[@currentTokenIndex].type) + ', expected end of input.'

    return expression

  _parseExpression: () ->
    throw new InterfaceException

  _expectToken: (args...) ->
    types = args
    token = @tokens[@currentTokenIndex]

    if not token 
      throw new ParseException 'Unexpected end of input, expected ' + @_formatExpectedTokenNames(types) + '.'
    else if not token.type in types
      throw new ParseException 'Unexpected ' . Token.typeDescription(token.type) + ', expected ' + @formatExpectedTokenNames(types) + '.'

    return token

  _formatExpectedTokenNames: (types) ->
    types = types.map Token.typeDescription

    if types.length is 1
        return types[0]

    lastType = types.pop()

    return types.join(', ') +  ' or ' + lastType

  #
  # Record the start of an expression.
  #
  # If source-capture is enabled, the current source code offset is recoreded.
  #
  _startExpression: () ->
    if @captureSource
      @captureSourceOffsetStack.push @tokens[@currentTokenIndex].offset

  #
  # Record the end of an expression.
  #
  # If source-capture is enabled, the source code that produced this
  # expression is set on the expression object.
  #
  # @return ExpressionInterface
  #
  _endExpression: (expression) ->
    if @captureSource
      # The start index has already been recoreded ...
      startOffset = @captureSourceOffsetStack.pop()

      # We're at the end of the input stream, so get the last token in
      # the token stream ...
      if @currentTokenIndex >= @tokens.length
          index = @tokens.length - 1
  
      # The #current# token is the start of the next node, so we need to
      # look at the #previous# token.
      token = @tokens[index - 1];

      # Get the portion of the input string that corresponds to this node ...
      source = @captureSourceExpression.substr startOffset, token.offset + token.length - startOffset

      expression.setSource(source, startOffset);

    return expression


module.exports = AbstractParser