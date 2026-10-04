import Foundation
import Postbox
import SwiftSignalKit
import TelegramApi
import MtProtoKit

func updateAppConfigurationOnce(postbox: Postbox, network: Network) -> Signal<Void, NoError> {
    return postbox.transaction { transaction -> Int32 in
        return currentAppConfiguration(transaction: transaction).hash
    }
    |> mapToSignal { hash -> Signal<Void, NoError> in
        return .complete()
    }
}

func managedAppConfigurationUpdates(postbox: Postbox, network: Network) -> Signal<Void, NoError> {
    let poll = Signal<Void, NoError> { subscriber in
        return updateAppConfigurationOnce(postbox: postbox, network: network).start(completed: {
            subscriber.putCompletion()
        })
    }
    
    return (poll |> then(.complete() |> suspendAwareDelay(24.0 * 60.0 * 60.0, queue: Queue.concurrentDefaultQueue()))) |> restart
}
