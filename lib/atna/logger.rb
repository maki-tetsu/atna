# -*- coding: utf-8 -*-
require "socket"

# ATNA 監査証跡対応版ライブラリ
#
# ログの送信にのみ利用します。
# 監査メッセージ本体は別途対応
module ATNA
  class Logger
    # ATNA メッセージ構築用パラメータ
    VALID_OPTIONS = [:pri, :version, :timestamp, :hostname, :app_name, :procid, :msgid, :structured_data]
    # ATNA 用の UTF-8 BOMB
    UTF8_BOMB = 0xEFBBBF
    # PRI の値
    PRI = "<85>"
    # MSGID の値(ATNA では固定値)
    MSGID = "IHE+RFC-3881"

    def initialize(host = 'localhost', port = 514, default_options = { })
      @host, @port = host, port
      @default_options = default_options
    end

    # メッセージを送信
    #
    # xmlmsg :: 送信すべき XML メッセージ本体
    # options ::
    #   :version :: バージョン番号
    #   :timestamp :: Time インスタンス(未指定時は現在時刻を利用)
    #   :hostname :: メッセージ発信元 hostname(未指定時はホスト名を取得:localhost時は - を設定)
    #   :app_name :: アプリケーション名(未指定時は - を設定)
    #   :procid :: プロセスID(未指定時は - を設定)
    #   :msgid :: メッセージID(未指定時は - を設定)
    #   :structured_data :: 構造化データ
    def notify!(xmlmsg, options = { })
      options = @default_options.merge(options)
      validate_options(options)
      update_blank_options(options)

      sender = UdpSender.new(@host, @port)
      datagram = serialize_message(xmlmsg, options)
      sender.send(datagram)
    end

    private

    def validate_options(options)
      unless (unknown_options = options.keys - VALID_OPTIONS).empty?
        raise ArgumentError, "Unknown option keys(#{unknown_options.join(", ")})"
      end
    end

    def update_blank_options(options)
      VALID_OPTIONS.each do |key|
        if options[key].nil? || options[key].empty?
          case key
          when :pri
            options[key] = PRI
          when :timestamp
            options[key] = Time.now
          when :hostname
            options[key] = Socket.gethostname
            options[key] = "-" if options[key] == "localhost"
          when :msgid
            options[key] = MSGID
          else
            options[key] = "-"
          end
        end
      end
    end

    def serialize_message(xmlmsg, options)
      buf = StringIO.new("wb")
      # HEADER
      buf.write("#{options[:pri]}#{options[:version]} #{options[:timestamp].utc.iso8601} ")
      buf.write("#{options[:hostname]} #{options[:app_name]} #{options[:procid]} ")
      buf.write("#{options[:msgid]}")
      buf.write(" ")

      # 構造化データ
      buf.write("#{options[:structured_data]}")
      buf.write(" ")

      # MSG
      buf.write(UTF8_BOMB)
      buf.write(xmlmsg)

      # 巻き戻し
      buf.rewind
      return buf.string
    end
  end
end
