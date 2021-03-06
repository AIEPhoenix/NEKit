import Foundation
import CocoaLumberjackSwift

/// The rule matches the request based on the geographical location of the corresponding IP address.
public class CountryRule: Rule {
    private let adapterFactory: AdapterFactory

    /// The ISO code of the country.
    public let countryCode: String

    /// The rule should match the request which matches the country or not.
    public let match: Bool

    public override var description: String {
        return "<CountryRule countryCode:\(countryCode) match:\(match)>"
    }

    /**
     Create a new `CountryRule` instance.

     - parameter countryCode:    The ISO code of the country.
     - parameter match:          The rule should match the request which matches the country or not.
     - parameter adapterFactory: The factory which builds a corresponding adapter when needed.
     */
    public init(countryCode: String, match: Bool, adapterFactory: AdapterFactory) {
        self.countryCode = countryCode
        self.match = match
        self.adapterFactory = adapterFactory
        super.init()
    }

    /**
     Match DNS request to this rule.

     - parameter session: The DNS session to match.
     - parameter type:    What kind of information is available.

     - returns: The result of match.
     */
    override func matchDNS(session: DNSSession, type: DNSSessionMatchType) -> DNSSessionMatchResult {
        guard type == .IP else {
            return .Unknown
        }

        if (session.countryCode != countryCode) != match {
            if let _ = adapterFactory as? DirectAdapterFactory {
                return .Real
            } else {
                return .Fake
            }
        }
        return .Pass
    }

    /**
     Match connect request to this rule.

     - parameter request: Connect request to match.

     - returns: The configured adapter if matched, return `nil` if not matched.
     */
    override func match(request: ConnectRequest) -> AdapterFactory? {
        if (request.country != countryCode) != match {
            return adapterFactory
        }
        return nil
    }
}
