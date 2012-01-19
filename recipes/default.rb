
node['oh_my_zsh']['users'].each do |user_hash|
  package "zsh"
  include_recipe "git"
  home_directory = `cat /etc/passwd | grep "#{user_hash[:login]}" | cut -d ":" -f6`.chop

  git "#{home_directory}/.oh-my-zsh" do
    repository 'git://github.com/robbyrussell/oh-my-zsh.git'
    user user_hash[:login]
    reference "master"
    action :sync
  end

  template "#{home_directory}/.zshrc" do
    source "zshrc.erb"
    owner user_hash[:login]
    mode "644"
    variables({
      :user => user_hash[:login],
      :theme => user_hash[:theme] || 'robbyrussell',
      :case_sensitive => user_hash[:case_sensitive] || false,
      :plugins => user_hash[:plugins]
    })
  end

  execute "change shell to user #{user_hash[:login]}" do
    command "chsh -s /bin/zsh #{user_hash[:login]}"
  end

end
