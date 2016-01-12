crypto = require 'crypto'
http   = require 'http'
TokenManager = require 'meshblu-core-manager-token'

class RemoveTokenCache
  constructor: (options={}) ->
    {cache,pepper,uuidAliasResolver} = options
    @tokenManager = new TokenManager {pepper, uuidAliasResolver, cache}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    return @_doCallback request, 404, callback unless uuid? and token?

    @tokenManager.removeTokenFromCache uuid, token, (error) =>
      return callback error if error?
      @_doCallback request, 204, callback

module.exports = RemoveTokenCache
