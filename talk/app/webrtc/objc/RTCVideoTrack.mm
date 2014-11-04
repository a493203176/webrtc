/*
 * libjingle
 * Copyright 2013, Google Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "RTCVideoTrack+Internal.h"

#import "RTCMediaStreamTrack+Internal.h"
#import "RTCVideoRendererAdapter.h"

@implementation RTCVideoTrack {
  NSMutableArray* _adapters;
}

- (id)initWithMediaTrack:
          (rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>)
      mediaTrack {
  if (self = [super initWithMediaTrack:mediaTrack]) {
    _adapters = [NSMutableArray array];
  }
  return self;
}

- (void)addRenderer:(id<RTCVideoRenderer>)renderer {
  // Make sure we don't have this renderer yet.
  for (RTCVideoRendererAdapter* adapter in _adapters) {
    NSParameterAssert(adapter.videoRenderer != renderer);
  }
  // Create a wrapper that provides a native pointer for us.
  RTCVideoRendererAdapter* adapter =
      [[RTCVideoRendererAdapter alloc] initWithVideoRenderer:renderer];
  [_adapters addObject:adapter];
  self.nativeVideoTrack->AddRenderer(adapter.nativeVideoRenderer);
}

- (void)removeRenderer:(id<RTCVideoRenderer>)renderer {
  RTCVideoRendererAdapter* adapter = nil;
  NSUInteger indexToRemove = NSNotFound;
  for (NSUInteger i = 0; i < _adapters.count; i++) {
    adapter = _adapters[i];
    if (adapter.videoRenderer == renderer) {
      indexToRemove = i;
      break;
    }
  }
  if (indexToRemove == NSNotFound) {
    return;
  }
  self.nativeVideoTrack->RemoveRenderer(adapter.nativeVideoRenderer);
  [_adapters removeObjectAtIndex:indexToRemove];
}

@end

@implementation RTCVideoTrack (Internal)

- (rtc::scoped_refptr<webrtc::VideoTrackInterface>)nativeVideoTrack {
  return static_cast<webrtc::VideoTrackInterface*>(self.mediaTrack.get());
}

@end
