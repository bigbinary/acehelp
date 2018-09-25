module Admin.Request.Setting exposing
    ( requestOrganizationSetting
    , requestUpdateBaseUrlSetting
    , requestUpdateVisibilitySetting
    )

import Admin.Data.Setting exposing (..)
import Admin.Request.Helper exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Task exposing (Task)


requestUpdateVisibilitySetting : UpdateSettingInputs -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error SettingsResponse)
requestUpdateVisibilitySetting settingInputs =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    { visibility = settingInputs.visibility
                    }
                    updateVisibilityMutation
        )


requestUpdateBaseUrlSetting : { base_url : String } -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error SettingsResponse)
requestUpdateBaseUrlSetting settingInputs =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    { visibility = settingInputs.base_url
                    }
                    updateBaseUrlMutation
        )


requestOrganizationSetting : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Setting)
requestOrganizationSetting =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request [] organizationSettingQuery
        )
