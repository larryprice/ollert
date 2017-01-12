require 'json'

class LabelCountFetcher
  def self.fetch(client, board_id)
    raise Trello::Error if client.nil? || board_id.nil? || board_id.empty?

    cards = []
    before = nil
    loop do
      newCards = JSON.parse(client.get("/boards/#{board_id}/cards", {
        fields: "labels,idList,closed",
        limit: 1000,
        before: before,
        filter: :all
      }))
      cards.concat newCards
      break unless newCards.count == 1000
      before = newCards.first['actions'][0]["date"]
    end
    cards
  end
end
