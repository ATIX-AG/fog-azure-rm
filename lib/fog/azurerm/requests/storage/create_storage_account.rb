module Fog
  module Storage
    class AzureRM
      # This class provides the actual implemention for service calls.
      class Real
        def create_storage_account(storage_account_hash)
          msg = "Creating Storage Account: #{storage_account_hash[:name]}in Resource Group #{storage_account_hash[:resource_group]}."
          Fog::Logger.debug msg
          storage_account_params = get_storage_account_params(storage_account_hash[:account_type],
                                                              storage_account_hash[:location],
                                                              storage_account_hash[:replication])
          begin
            response = @storage_mgmt_client.storage_accounts.create(storage_account_hash[:resource_group],
                                                                    storage_account_hash[:name],
                                                                    storage_account_params)
            Fog::Logger.debug 'Storage Account created successfully.'
            response
          rescue MsRestAzure::AzureOperationError => e
            raise_azure_exception(e, msg)
          end
        end

        private

        def get_storage_account_params(sku_name, location, replication)
          params = Azure::ARM::Storage::Models::StorageAccountCreateParameters.new
          sku = Azure::ARM::Storage::Models::Sku.new
          sku.name = "#{sku_name}_#{replication}"
          params.sku = sku
          params.kind = Azure::ARM::Storage::Models::Kind::Storage
          params.location = location
          params
        end
      end
      # This class provides the mock implementation for unit tests.
      class Mock
        def create_storage_account(*)
          {
            'location' => 'West US',
            'properties' =>
            {
              'accountType' => 'Standard_LRS',
              'lastGeoFailoverTime' => DateTime.parse(Time.now.to_s).strftime('%FT%TZ'),
              'creationTime' => DateTime.parse(Time.now.to_s).strftime('%FT%TZ')
            }
          }
        end
      end
    end
  end
end
