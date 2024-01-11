extends Node


signal message_received(message: String)
signal chirp_received(chirp: String)
signal chirp_send()
signal chirp_send_complete()
signal message_send(message: String)
signal message_send_complete(message: String)
signal channel_change(channel: String)
signal channel_change_complete(channel: String)

signal message_handler_ready()

