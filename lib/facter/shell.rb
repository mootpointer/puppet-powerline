Facter.add(:shell) do
  setcode do
    ENV['SHELL'].split("/").last
  end
end
