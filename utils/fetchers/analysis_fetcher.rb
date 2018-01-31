require_relative 'fetcher'
require_relative '../list_action'

module Utils
  module Fetchers
    class AnalysisFetcher
      extend Utils::Fetcher

      def self.fetch(client, board_id, options={})
        raise Trello::Error if client.nil? || board_id.nil? || board_id.empty?

        boardOptions = {
          actions: "createCard,updateCard:idList,convertToCardFromCheckItem,moveCardToBoard,updateCard:closed",
          action_fields: "data,type,date,idMemberCreator",
          action_member: false,
          action_memberCreator: false,
          actions_limit: 1000,
          labels: "all",
          label_fields: "id,name,color",
          members: "all",
          member_fields: "id,username",
          lists: "all",
          list_fields: "id,name,closed",
        }.merge(options)
        results = project(client.get("/boards/#{board_id}", options), false)
        results["actions"] = project(results["actions"], ListAction)

        actionOptions = {
          result_to: ListAction,
          filter: "createCard,updateCard:idList,convertToCardFromCheckItem,moveCardToBoard,updateCard:closed",
          fields: "data,type,date,idMemberCreator",
          member: false,
          memberCreator: false,
          before: oldest_date_for(results)
        }.merge(options)
        results["actions"] += all(client, "/boards/#{board_id}/actions", actionOptions)

        results
      end
    end
  end
end
