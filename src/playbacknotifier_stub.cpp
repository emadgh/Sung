#include "playbacknotifier.h"

PlaybackNotifier::PlaybackNotifier(QObject *parent) : QObject(parent) {}

void PlaybackNotifier::show(const QString &, const QString &) {}
void PlaybackNotifier::clear() {
  m_queued.clear();
  m_id = 0;
  m_pending = false;
  ++m_generation;
}
void PlaybackNotifier::notificationClosed(uint, uint) {}
void PlaybackNotifier::flush() {}
void PlaybackNotifier::close(uint) {}
