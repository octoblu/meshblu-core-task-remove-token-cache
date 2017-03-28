http         = require 'http'
TokenManager = require 'meshblu-core-manager-token'

class RemoveTokenCache
  constructor: (options={}) ->
    {@cache,pepper,@uuidAliasResolver} = options
    @tokenManager = new TokenManager {pepper, @uuidAliasResolver}

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

    @_removeTokenFromCache {uuid, token}, (error) =>
      return callback error if error?
      @_doCallback request, 204, callback

  _removeTokenFromCache: ({uuid, token}, callback) =>
    @uuidAliasResolver.resolve uuid, (error, uuid) =>
      return callback error if error?
      hashedToken = @tokenManager.hashToken { uuid, token}
      return callback new Error 'Unable to hash token' unless hashedToken?
      @cache.del "#{uuid}:#{hashedToken}", callback

module.exports = RemoveTokenCache
