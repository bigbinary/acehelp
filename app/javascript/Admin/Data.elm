module Admin.Data exposing (fetchOrganizationsQuery)

import Admin.Data.Organization exposing (Organization, organizationObject)
import GraphQL.Request.Builder as GQLBuilder


fetchOrganizationsQuery : GQLBuilder.Document GQLBuilder.Query (Maybe (List Organization)) {}
fetchOrganizationsQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "organization_list"
                []
                (GQLBuilder.nullable
                    (GQLBuilder.list
                        organizationObject
                    )
                )
            )
        )
