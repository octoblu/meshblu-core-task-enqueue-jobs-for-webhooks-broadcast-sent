http           = require 'http'
WebhookManager = require 'meshblu-core-manager-webhook'

class EnqueueJobsForWebhooksBroadcastSent
  constructor: (options) ->
    {datastore, jobManager, uuidAliasResolver} = options
    @webhookManager = new WebhookManager {datastore, jobManager, uuidAliasResolver}

  do: (request, callback) =>
    @webhookManager.enqueueForSent {
      uuid: request.metadata.auth.uuid
      route: request.metadata.route
      forwardedRoutes: request.metadata.forwardedRoutes
      rawData: request.rawData
      type: 'broadcast.sent'
    }, (error) =>
      return @_doErrorCallback request, error, callback if error?
      @_doCallback request, 204, callback

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  _doErrorCallback: (request, error, callback) =>
    code = error.code ? 500
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
        error:
          message: error.message
    callback null, response

module.exports = EnqueueJobsForWebhooksBroadcastSent
