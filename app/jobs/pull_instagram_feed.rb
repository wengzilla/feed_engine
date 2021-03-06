require './app/lib/instagram_processor'

class PullInstagramFeed
  @queue = :instagram

  def self.perform
    instagram_processor = Hungrlr::InstagramProcessor.new
    instagram_processor.run
  end
end
