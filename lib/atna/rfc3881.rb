require "nokogiri"
require "atna/utils"

module ATNA
  # ATNA::RFC3881
  #
  # Build RFC 3881 Message(xml) Builder.
  # Message building by +ATNA::RFC3881::AuditMessage.new+ and add child element +<<+ or
  # +add_child+ method.
  #
  # Example:
  #   include ATNA::RFC3881
  #
  #   msg = AuditMessage.new
  #   msg << AuditMessage::EventParticipant.new(:UserID => "user1",
  #                                             "RoleIDCode" => [{ :code => "1" }, { :code => "2" }])
  #   msg << AuditMessage::EventIdentification.new(:EventActionCode => AuditMessage::EventIdentification::EVENT_ACTION_CODE["Create"],
  #                                                :EventDateTime => Time.now.utc.iso8601,
  #                                                :EventOutcomeIndicator => AuditMessage::EventIdentification::EVENT_OUTCOME_INDICATOR["Success"],
  #                                                "EventID" => { :code => "1" },
  #                                                "EventTypeCode" => [{ :code => "2" }, { :code => "3" }])
  #   msg << AuditMessage::ActiveParticipant.new(:UserID => "user2",
  #                                              "RoleIDCode" => [{ :code => "1" }, { :code => "2" }])
  #   # ...
  module RFC3881
    class AuditMessage < ATNA::Utils::XmlBuilder::Base
      class EventIdentification < ATNA::Utils::XmlBuilder::Base
        EVENT_ACTION_CODE = {
          "Create"  => "C",
          "Read"    => "R",
          "Update"  => "U",
          "Delete"  => "D",
          "Execute" => "E",
        }

        EVENT_OUTCOME_INDICATOR = {
          "Success"                                => 0,
          "Minor failure"                          => 4,
          "Serious failure"                        => 8,
          "Major failure; action mode unavailable" => 12,
        }

        attributes :EventActionCode, :EventDateTime, :EventOutcomeIndicator

        class EventID < ATNA::Utils::XmlBuilder::Base
          attributes :code, :codeSystem, :codeSystemName, :displayName, :originalText
        end

        class EventTypeCode < ATNA::Utils::XmlBuilder::Base
          attributes :code, :codeSystem, :codeSystemName, :displayName, :originalText
        end

        children_order EventID, EventTypeCode
      end

      class ActiveParticipant < ATNA::Utils::XmlBuilder::Base
        NETWORK_ACCESS_POINT_TYPE_CODE = {
          "Machine Name, including DNS namee" => 1,
          "IP Address"                        => 2,
          "Telephone Number"                  => 3,
        }

        attributes :UserID, :AlternativeUserID, :UserName, :UserIsRequester
        attributes :NetworkAccessPointID, :NetworkAccessPointTypeCode

        class RoleIDCode < ATNA::Utils::XmlBuilder::Base
          attributes :code, :codeSystem, :codeSystemName, :displayName, :originalText
        end

        children_order RoleIDCode
      end

      class AuditSourceIdentification < ATNA::Utils::XmlBuilder::Base
        attributes :AuditEnterpriseSiteID, :AuditSourceID

        class AuditSourceTypeCode < ATNA::Utils::XmlBuilder::Base
          AUDIT_SOURCE_TYPE_CODE = {
            "End-user display device, diagnostic display" => "1",
            "Data acquisition device or instrument"       => "2",
            "Web server process"                          => "3",
            "Application server process"                  => "4",
            "Database server process"                     => "5",
            "Security server, e.g., a domain controller"  => "6",
            "ISO level 1-3 network component"             => "7",
            "ISO level 4-6 operating software"            => "8",
            "External source, other or unknown type"      => "9",
          }

          attributes :code, :codeSystem, :codeSystemName, :displayName, :originalText
        end

        children_order AuditSourceTypeCode
      end

      class ParticipantObjectIdentification < ATNA::Utils::XmlBuilder::Base
        PARTICIPANT_OBJECT_ID_TYPE_CODE = {
          "Medical Record Number"  => "1",
          "Patient Number"         => "2",
          "Encounter Number"       => "3",
          "Enrollee Number"        => "4",
          "Social Security Number" => "5",
          "Account Number"         => "6",
          "Guarantor Number"       => "7",
          "Report Name"            => "8",
          "Report Number"          => "9",
          "Search Criteria"        => "10",
          "User Identifier"        => "11",
          "URI"                    => "12",
          ""                       => "",
        }

        PARTICIPANT_OBJECT_TYPE_CODE = {
          "Person"        => 1,
          "System object" => 2,
          "Organization"  => 3,
          "Other"         => 4,
        }

        PARTICIPANT_OBJECT_TYPE_CODE_ROLE = {
          "Patient"                          => 1,
          "Location"                         => 2,
          "Report"                           => 3,
          "Resource"                         => 4,
          "Master file"                      => 5,
          "User"                             => 6,
          "List"                             => 7,
          "Doctor"                           => 8,
          "Subscriber"                       => 9,
          "Guarantor"                        => 10,
          "Security User Entity"             => 11,
          "Security User Group"              => 12,
          "Security Resource"                => 13,
          "Security Granualarity Definition" => 14,
          "Provider"                         => 15,
          "Report Destination"               => 16,
          "Report Library"                   => 17,
          "Schedule"                         => 18,
          "Customer"                         => 19,
          "Job"                              => 20,
          "Job Stream"                       => 21,
          "Table"                            => 22,
          "Routing Criteria"                 => 23,
          "Query"                            => 24,
        }

        PARTICIPANT_OBJECT_DATA_LIFE_CYCLE = {
          "Origination / Creation"                   => 1,
          "Import / Copy from original"              => 2,
          "Amendment"                                => 3,
          "Verification"                             => 4,
          "Translation"                              => 5,
          "Access / Use"                             => 6,
          "De-identification"                        => 7,
          "Aggregation, summarization, derivation"   => 8,
          "Report"                                   => 9,
          "Export / Copy to target"                  => 10,
          "Disclosure"                               => 11,
          "Receipt of disclosure"                    => 12,
          "Archiving"                                => 13,
          "Logical deletion"                         => 14,
          "Permanent erasure / Physical destruction" => 15,
        }

        attributes :ParticipantObjectID, :ParticipantObjectTypeCode
        attributes :ParticipantObjectTypeCodeRole, :ParticipantObjectDataLifeCycle
        attributes :ParticipantObjectSensitivity

        class ParticipantObjectIDTypeCode < ATNA::Utils::XmlBuilder::Base
          attributes :code, :codeSystem, :codeSystemName, :displayName, :originalText
        end

        class ParticipantObjectName < ATNA::Utils::XmlBuilder::Base
        end

        class ParticipantObjectQuery < ATNA::Utils::XmlBuilder::Base
        end

        class ParticipantObjectDetail < ATNA::Utils::XmlBuilder::Base
          attributes :type, :value
        end

        children_order ParticipantObjectIDTypeCode, ParticipantObjectName, ParticipantObjectQuery, ParticipantObjectDetail
      end

      children_order EventIdentification, ActiveParticipant, AuditSourceIdentification, ParticipantObjectIdentification
    end
  end
end
