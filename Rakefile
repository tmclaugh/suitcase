# Rakefile around our Packer build

load "./site.rb"

MASTER_DIR  = 'images/master'
AWS_HVM_DIR = 'images/aws-hvm'
AWS_PV_DIR  = 'images/aws-paravirt'
VG_DIR      = 'images/vagrant'

AWS_HVM_TMPL = 'image-templates/aws-hvm.json'
AWS_PV_TMPL  = 'image-templates/aws-paravirt.json'
MASTER_TMPL  = 'image-templates/virtualbox.json'
VAGRANT_TMPL = 'image-templates/vagrant.json'

S3_MASTER  = "#{S3_BUCKET}/master"
S3_VAGRANT = "#{S3_BUCKET}/vagrant"
S3_AWS_HVM = "#{S3_BUCKET}/aws-hvm"
S3_AWS_PV  = "#{S3_BUCKET}/aws-pv"

if RUBY_PLATFORM =~ /.*darwin.*/
  packer_cmd = '/usr/local/bin/packer'
else
  packer_cmd = '~/bin/packer'
end

$command = { 'packer' => packer_cmd }

namespace :packer do

  if ENV['os']
    os=ENV['os']
    os_name=os.split('.')[0..-2].join('.')
  end

  if ENV['timestamp']
    timestamp = ENV['timestamp']
  else
    timestamp = Time.new.strftime("%Y%m%d%H%M%S")
  end

  master_image  = "#{MASTER_DIR}/#{os_name}-#{timestamp}/#{os_name}-#{timestamp}-disk1.vmdk"
  vagrant_image = "#{VG_DIR}/#{os_name}-#{timestamp}.box"
  aws_hvm_image = "#{AWS_HVM_DIR}/#{os_name}-#{timestamp}/#{os_name}-#{timestamp}-aws-hvm-disk1.vmdk"
  aws_pv_image  = "#{AWS_PV_DIR}/#{os_name}-#{timestamp}/#{os_name}-#{timestamp}-aws-paravirt-disk1.vmdk"

  master_upload_done  = "#{master_image}.upload_done"
  vagrant_upload_done = "#{vagrant_image}.upload_done"
  aws_hvm_upload_done  = "#{aws_hvm_image}.upload_done"
  aws_pv_upload_done   = "#{aws_pv_image}.upload_done"

  def build_image(os, timestamp, template)
    if os == nil
      abort("ERROR: no os defined!")
    end
    sh %{ #{$command['packer']} build -var-file=#{os} -var timestamp=#{timestamp} #{template} }
  end


  # Basic tasks
  desc "Build images"
  task :build, [:image] do |t, args|
    args.with_defaults(:image => :all)
    image = args[:image]
    Rake::Task["packer:build_#{image}"].invoke
  end

  desc "Build all images"
  task :build_all => [:build_vagrant, :build_awshvm, :build_awspv]

  desc "Clean artifacts"
  task :clean, [:image] do |t, args|
    if os == nil
      abort("ERROR: no os defined!")
    end

    args.with_defaults(:image => :all)
    image = args[:image]
    Rake::Task["packer:clean_#{image}"].invoke
  end

  task :clean_all => ['clean_vagrant', 'clean_awshvm', 'clean_awspv', 'clean_master']

  desc "Upload artifacts"
  task :upload, [:image] do |t, args|
    args.with_defaults(:image => :all)
    image = args[:image]
    Rake::Task["packer:upload_#{image}"].invoke
  end

  task :upload_all => ['upload_master', 'upload_vagrant', 'upload_awshvm', 'upload_awspv']

  desc "Fake upload artifacts"
  task :fake_upload, [:image] do |t, args|
    args.with_defaults(:image => :all)
    image = args[:image]
    Rake::Task["packer:fake_upload_#{image}"].invoke
  end

  task :fake_upload_all => ['fake_upload_master', 'fake_upload_vagrant', 'fake_upload_awshvm', 'fake_upload_awspv']

  desc "Fetch images"
  task :fetch, [:image] do |t, args|
    args.with_defaults(:image => :all)
    image = args[:image]
    Rake::Task["packer:fetch_#{image}"].invoke
  end

  task :fetch_all => ['fetch_master', 'fetch_vagrant', 'fetch_awshvm', 'fetch_awspv']

  desc "Register images"
  task :register, [:image] do |t, args|
    args.with_defaults(:image => :all)
    image = args[:image]
    Rake::Task["packer:register_#{image}"].invoke
  end

  task :register_all => ['register_master', 'register_vagrant', 'register_awshvm', 'register_awspv']

  desc "Delete images from S3"
  task :delete, [:image] do |t, args|
    args.with_defaults(:image => :all)
    image = args[:image]
    Rake::Task["packer:delete_#{image}"].invoke
  end

  task :delete_all => ['delete_master', 'delete_vagrant', 'delete_awshvm', 'delete_awspv']



  # Master image related tasks.
  desc "Build master image"
  task :build_master => "#{master_image}"

  file "#{master_image}" do
    build_image(os, timestamp, MASTER_TMPL)
  end

  desc "Upload master image"
  task :upload_master => :build_master do
    unless FileUtils.uptodate?("#{master_upload_done}", ["#{master_image}"])
      sh %{aws --profile #{AWS_PROFILE} s3 cp --recursive #{File.dirname("#{master_image}")} #{S3_MASTER}/#{File.basename(File.dirname("#{master_image}"))}}
      FileUtils.touch("#{master_upload_done}")
    end
  end

  desc "Pretend we uploaded a master image"
  task :fake_upload_master => :build_master do
    FileUtils.touch("#{master_upload_done}")
  end

  desc "Register master image (NOOP procedure)"
  task :register_master => :upload_master

  desc "Fetch master image"
  task :fetch_master do
    unless File.exist?("#{master_image}")
      sh %{aws --profile #{AWS_PROFILE} s3 cp --recursive #{S3_MASTER}/#{File.basename(File.dirname("#{master_image}"))} #{File.dirname("#{master_image}")}}
    end
  end

  desc "Cleanup master image"
  task :clean_master do
    if File.exist?("#{master_image}")
      File.delete("#{master_image}")
      FileUtils.rm_rf(File.dirname("#{master_image}"))
    end
  end

  desc "Delete master image from S3"
  task :delete_master do
    sh %{aws --profile #{AWS_PROFILE} s3 rm --recursive #{S3_MASTER}/#{File.basename(File.dirname("#{master_image}"))}}
  end


  # Vagrant related tasks
  desc "Build Vagrant"
  task :build_vagrant => "#{vagrant_image}"

  file "#{vagrant_image}" => :build_master do
    build_image(os, timestamp, VAGRANT_TMPL)
  end

  desc "Upload Vagrant image"
  task :upload_vagrant => :build_vagrant do
    unless FileUtils.uptodate?("#{vagrant_upload_done}", ["#{vagrant_image}"])
      sh %{aws --profile #{AWS_PROFILE} s3 cp #{vagrant_image} #{S3_VAGRANT}/}
      FileUtils.touch("#{vagrant_upload_done}")
    end
  end

  desc "Pretend we uploaded a Vagrant image"
  task :fake_upload_vagrant => :build_vagrant do
    FileUtils.touch("#{vagrant_upload_done}")
  end

  desc "Register Vagrant image (NOOP procedure)"
  task :register_vagrant => :upload_vagrant

  desc "Fetch vagrant image"
  task :fetch_vagrant do
    unless File.exist?("#{vagrant_image}")
      sh %{aws --profile #{AWS_PROFILE} s3 cp #{S3_VAGRANT}/#{File.basename("#{vagrant_image}")} #{File.dirname("#{vagrant_image}")}}
    end
  end

  desc "Cleanup Vagrant"
  task :clean_vagrant do
    if File.exists?("#{vagrant_image}")
      File.delete("#{vagrant_image}")
      File.delete("#{vagrant_upload_done}")
    end
  end

  desc "Delete Vagrant image from S3"
  task :delete_vagrant do
    sh %{aws --profile #{AWS_PROFILE} s3 rm --recursive #{S3_VAGRANT}/#{File.basename(File.dirname("#{vagrant_image}"))}}
  end


  # AWS HVM related tasks
  desc "Build AWS HVM"
  task :build_awshvm => "#{aws_hvm_image}"

  file "#{aws_hvm_image}" => :build_master do
    build_image(os, timestamp, AWS_HVM_TMPL)
  end

  desc "Upload AWS HVM image"
  task :upload_awshvm => :build_awshvm do
    unless FileUtils.uptodate?("#{aws_hvm_upload_done}", ["#{aws_hvm_image}"])
      sh %{aws --profile #{AWS_PROFILE} s3 cp --recursive #{File.dirname("#{aws_hvm_image}")} #{S3_AWS_HVM}/#{File.basename(File.dirname("#{aws_hvm_image}"))}}
      FileUtils.touch("#{aws_hvm_upload_done}")
    end
  end

  desc "Pretend we uploaded an AWS HVM image"
  task :fake_upload_awshvm => :build_awshvm do
    FileUtils.touch("#{aws_hvm_upload_done}")
  end

  desc "Register AWS HVM with SR-IOV support"
  task :register_awshvm => :upload_awshvm do
    sh %{sh files/registerami.sh -i #{aws_hvm_image} -t hvm -a #{PROD_ACCOUNTNUM} -b #{PROD_BUCKET}}
  end

  desc "Fetch AWS HVM image"
  task :fetch_awshvm do
    unless File.exist?("#{aws_hvm_image}")
      sh %{aws --profile #{AWS_PROFILE} s3 cp --recursive #{S3_AWS_HVM}/#{File.basename(File.dirname("#{aws_hvm_image}"))} #{File.dirname("#{aws_hvm_image}")}}
    end
  end

  desc "Cleanup AWS HVM image"
  task :clean_awshvm do
    if File.exists?("#{aws_hvm_image}")
      sh %{VBoxManage closemedium disk #{aws_hvm_image} --delete}
      FileUtils.rm_rf(File.dirname("#{aws_hvm_image}"))
    end
  end

  desc "Delete AWS HVM image from S3"
  task :delete_awshvm do
    sh %{aws --profile #{AWS_PROFILE} s3 rm --recursive #{S3_AWS_HVM}/#{File.basename(File.dirname("#{aws_hvm_image}"))}}
  end


  # AWS PV related tasks
  desc "Build AWS paravirt"
  task :build_awspv => "#{aws_pv_image}"

  file "#{aws_pv_image}" => :build_master do
    build_image(os, timestamp, AWS_PV_TMPL)
  end

  desc "Upload AWS paravirt image"
  task :upload_awspv => :build_awspv do
    unless FileUtils.uptodate?("#{aws_pv_upload_done}", ["#{aws_pv_image}"])
      sh %{aws --profile #{AWS_PROFILE} s3 cp --recursive #{File.dirname("#{aws_pv_image}")} #{S3_AWS_PV}/#{File.basename(File.dirname("#{aws_pv_image}"))}}
      FileUtils.touch("#{aws_pv_upload_done}")
    end
  end

  desc "Pretend we uploaded an AWS paravirt image"
  task :fake_upload_awspv => :build_awspv do
    FileUtils.touch("#{aws_pv_upload_done}")
  end

  desc "Register AWS paravirt image"
  task :register_awspv => :upload_awspv do
    sh %{sh files/registerami.sh -i #{aws_pv_image} -t paravirt -a #{PROD_ACCOUNTNUM} -b #{PROD_BUCKET}}
  end

  desc "Fetch AWS paravirt image"
  task :fetch_awspv do
    unless File.exist?("#{aws_pv_image}")
      sh %{aws --profile #{AWS_PROFILE} s3 cp --recursive #{S3_AWS_PV}/#{File.basename(File.dirname("#{aws_pv_image}"))} #{File.dirname("#{aws_pv_image}")}}
    end
  end

  desc "Cleanup AWS paravirt image"
  task :clean_awspv do
    if File.exists?("#{aws_pv_image}")
      sh %{VBoxManage closemedium disk #{aws_pv_image} --delete}
      FileUtils.rm_rf(File.dirname("#{aws_pv_image}"))
    end
  end

  desc "Delete AWS paravirt image from S3"
  task :delete_awspv do
    sh %{aws --profile #{AWS_PROFILE} s3 rm --recursive #{S3_AWS_PV}/#{File.basename(File.dirname("#{aws_pv_image}"))}}
  end


end
