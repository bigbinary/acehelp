module Admin.Request.Setting exposing (..)

import Admin.Request.Helper exposing (..)
import Admin.Data.Setting exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestUpdateSetting : UpdateSettingInputs -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Setting)
requestUpdateSetting settingInputs =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                (GQLBuilder.request
                    { visibility = settingInputs.visibility
                    }
                    updateSettingMutation
                )
        )
