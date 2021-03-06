require 'optparse'
require 'yaml'
require 'ipaddr'
require_relative 'volcano_log'

# magic values
VOLCANO_MIN_PORT=1025
VOLCANO_MAX_PORT=65535

# default server settings values
# (used only if a setting has not been defined
# either with CLI args or config file)
VOLCANO_DEFAULT_BIND = '127.0.0.1'
VOLCANO_DEFAULT_PORT = 4242

# paths
VOLCANO_CONFIG_FILE_PATH = './config.yml'

class VolcanoSettings
  attr_reader :settings

  def initialize
    @settings = {
        bind_ip: VOLCANO_DEFAULT_BIND,
        external_ip: VOLCANO_DEFAULT_BIND,
        port: VOLCANO_DEFAULT_PORT,
        root_dir: Pathname.new(Dir.home),
        log_mode: LOG_MODE_STD,
        log_path: nil
    }

    @set_external = false
    config_from_file
    config_from_cli
    @settings[:external_ip] = @settings[:bind_ip] unless @set_external
    @settings.freeze
  end

  private
  def set_bind_ip(bind)
    begin
      ip = IPAddr.new(bind)
      if ip.ipv6?
        VolcanoLog.log('Bind address: IPv6 is not supported, ignoring value', 0, LOG_ERROR)
      else
        @settings[:bind_ip] = ip.to_s
      end
    rescue; VolcanoLog.log("Bind address: Invalid IPv4 address '#{bind}', ignoring value", 0, LOG_ERROR)
    end
  end

  def set_external_ip(bind)
    begin
      ip = IPAddr.new(bind)
      if ip.ipv6?
        VolcanoLog.log('External IP: IPv6 is not supported, ignoring value', 0, LOG_ERROR)
      else
        @settings[:external_ip] = ip.to_s
        @set_external = true
      end
    rescue; VolcanoLog.log("External IP: Invalid IPv4 address '#{bind}', ignoring value", 0, LOG_ERROR)
    end
  end

  def set_port(port)
    if port.to_i >= VOLCANO_MIN_PORT && port.to_i <= VOLCANO_MAX_PORT
      @settings[:port] = port.to_i
    else
      VolcanoLog.log("Ignoring bad value '#{port}'", 0, LOG_ERROR)
    end
  end

  def set_root_dir(path)
    root = Pathname.new(path).expand_path
    if Dir.exists?(root)
      @settings[:root_dir] = root
    else
      VolcanoLog.log("Directory '#{root}' does not exists, falling back to default value.", 0, LOG_ERROR)
    end
  end

  def set_log_mode(mode)
    if mode == LOG_MODE_STD || mode == LOG_MODE_FILE
      @settings[:log_mode] |= mode
    elsif mode == LOG_MODE_SILENT
      @settings[:log_mode] &= ~LOG_MODE_STD
    else
      VolcanoLog.log('Log mode not set')
    end
  end

  def set_log_file(path)
    #if File.writable?(path)
      @settings[:log_path] = path
    #else
     # VolcanoLog.log('File not writable')
    #end
  end

  def config_from_file
    begin
      return unless File.exists?(VOLCANO_CONFIG_FILE_PATH)
      cfg = YAML.load_file(VOLCANO_CONFIG_FILE_PATH)
      set_bind_ip(cfg['bind_ip']) if cfg.keys.include?('bind_ip')
      set_external_ip(cfg['external_ip']) if cfg.keys.include?('external_ip')
      set_port(cfg['port']) if cfg.keys.include?('port')
      set_root_dir(cfg['root_dir']) if cfg.keys.include?('root_dir')
    rescue => e
      VolcanoLog.log(e.to_s)
      exit(1)
    end
  end

  def config_from_cli
    begin
      OptionParser.new { |opts|
        opts.banner = 'Usage: ./volcano_ftp.rb [options]'

        opts.on('-b', '--bind HOSTNAME_OR_IP') { |bind|
          set_bind_ip(bind)
        }
        opts.on('-e', '--external HOSTNAME_OR_IP') { |ip|
          set_external_ip(ip)
        }
        opts.on('-p', '--port PORT') { |port|
          set_port(port.to_i)
        }
        opts.on('-r', '--root DIR') { |path|
          set_root_dir(path)
        }
        opts.on('-s', '--silent') {
          set_log_mode(LOG_MODE_SILENT)
        }
        opts.on('-l', '--logfile PATH') { |path|
          set_log_mode(LOG_MODE_FILE)
          set_log_file(path)
        }
      }.parse!
    rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
      VolcanoLog.log(e)
      exit(1)
    end
  end
end

