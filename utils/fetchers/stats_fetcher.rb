require_relative 'action_fetcher'

class StatsFetcher
  include ActionFetcher

  def self.fetch(client, board_id)
    raise Trello::Error if client.nil? || board_id.nil? || board_id.empty?

    options = {
      fields: "name",
      actions: :createCard,
      action_fields: "date,data",
      action_memberCreator: :false,
      action_member: false,
      actions_limit: 1000,
      cards: :all,
      card_fields: "idList,name,idMembers,closed",
      members: :all,
      member_fields: :fullName,
      lists: :open,
      list_fields: "name,closed",
    }

    include_all_actions(JSON.parse(client.get("/boards/#{board_id}", options)), client, board_id)
  end

  private

  def self.include_all_actions(data, client, board_id)
    fetched = data["actions"].count
    while fetched == 1000
      new_actions = JSON.parse(self.fetch_actions(client, board_id,
        {before: data["actions"].last["date"], filter: :createCard, fields: "data,date"}))
      fetched = new_actions.count
      data["actions"].concat new_actions
    end
    data
  end
end
