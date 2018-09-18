module Admin.Request.Setting exposing (requestOrganizationSetting, requestUpdateSetting)

import Admin.Data.Setting exposing (..)
import Admin.Request.Helper exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Task exposing (Task)


requestUpdateSetting : UpdateSettingInputs -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Setting)
requestUpdateSetting settingInputs =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    { visibility = settingInputs.visibility
                    }
                    updateSettingMutation
        )


requestOrganizationSetting : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Setting)
requestOrganizationSetting =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request [] organizationSettingQuery
        )
