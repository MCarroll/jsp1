require "test_helper"

class AnnouncementTest < ActiveSupport::TestCase
  test "unread? returns false for guest when no announcements" do
    assert Announcement.unread?(nil)
  end

  test "unread? returns true for guest" do
    assert Announcement.unread?(nil)
  end

  test "unread? returns false when no announcements and never read" do
    user = users(:one)
    user.update(announcements_read_at: nil)
    Announcement.delete_all
    assert_not Announcement.unread?(user)
  end

  test "unread? returns false when no announcements" do
    user = users(:one)
    user.update(announcements_read_at: 1.month.ago)
    Announcement.delete_all
    assert_not Announcement.unread?(user)
  end

  test "unread? returns true with unread announcements" do
    user = users(:one)
    user.update(announcements_read_at: Announcement.maximum(:published_at) - 1.month)
    assert Announcement.unread?(user)
  end

  test "unread? returns false with no unread announcements" do
    user = users(:one)
    user.update(announcements_read_at: Announcement.maximum(:published_at) + 1.month)
    assert_not Announcement.unread?(user)
  end
end
