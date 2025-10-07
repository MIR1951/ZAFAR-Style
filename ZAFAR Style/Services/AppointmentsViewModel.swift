//import Foundation
//import Supabase
//
//final class AppointmentRepository: ObservableObject {
//    private let client = SupabaseManager.shared.client
//    private var channel: RealtimeChannelV2?
//    private var subscriptions = Set<RealtimeSubscription>()
//    
//    func subscribeToChanges(for barberID: UUID, handleChange: @escaping () -> Void) {
//        channel = client.realtime.channel("public:appointments")
//        
//        guard let ch = channel else { return }
//        
//        let insertToken = ch.onPostgresChange(event: .insert, schema: "public", table: "appointments", filter: "barber_id=eq.\(barberID.uuidString)") { _ in
//            print("🔄 Realtime update: INSERT")
//            handleChange()
//        }
//        insertToken.store(in: &subscriptions)
//        
//        let updateToken = ch.onPostgresChange(event: .update, schema: "public", table: "appointments", filter: "barber_id=eq.\(barberID.uuidString)") { _ in
//            print("🔄 Realtime update: UPDATE")
//            handleChange()
//        }
//        updateToken.store(in: &subscriptions)
//        
//        let deleteToken = ch.onPostgresChange(event: .delete, schema: "public", table: "appointments", filter: "barber_id=eq.\(barberID.uuidString)") { _ in
//            print("🔄 Realtime update: DELETE")
//            handleChange()
//        }
//        deleteToken.store(in: &subscriptions)
//        
//        Task {
//            _ = try? await ch.subscribe()
//        }
//    }
//    
//    deinit {
//        for token in subscriptions { token.cancel() }
//        subscriptions.removeAll()
//        if let channel {
//            Task { await channel.unsubscribe() }
//        }
//    }
//}
