module AnnouncementsHelper
  # Use the explicit names so they don't get purged
  ANNOUNCEMENT_COLORS = {
    "new" => "announcement-new",
    "update" => "announcement-update",
    "improvement" => "announcement-improvement",
    "fix" => "announcement-fix"
  }

  def announcement_color(announcement)
    ANNOUNCEMENT_COLORS.fetch(announcement.kind, "announcement-update")
  end

  def unread_announcements_class(user)
    "unread-announcements" if Announcement.unread?(user)
  end
end
