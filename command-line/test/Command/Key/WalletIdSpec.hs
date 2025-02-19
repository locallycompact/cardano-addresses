{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeApplications #-}

module Command.Key.WalletIdSpec
    ( spec
    ) where

import Prelude

import Test.Hspec
    ( Spec, SpecWith, it, shouldBe, shouldContain )
import Test.Utils
    ( cli, describeCmd )

spec :: Spec
spec = describeCmd [ "key", "walletid" ] $ do
    specKeyNeitherRootNorAcct "shelley" "1852H/1815H/0H/0/0" "--without-chain-code"
    specKeyNeitherRootNorAcct "shelley" "1852H/1815H/0H/0/0" "--with-chain-code"
    specKeyNeitherRootNorAcct "shelley" "1852H/1815H/0H/1/0" "--without-chain-code"
    specKeyNeitherRootNorAcct "shelley" "1852H/1815H/0H/1/0" "--with-chain-code"
    specKeyNeitherRootNorAcct "shelley" "1852H/1815H/0H/2/0" "--without-chain-code"
    specKeyNeitherRootNorAcct "shelley" "1852H/1815H/0H/2/0" "--with-chain-code"

    specKeyNeitherRootNorAcct "icarus" "1852H/1815H/0H/0/0" "--without-chain-code"
    specKeyNeitherRootNorAcct "icarus" "1852H/1815H/0H/0/0" "--with-chain-code"
    specKeyNeitherRootNorAcct "icarus" "1852H/1815H/0H/1/0" "--without-chain-code"
    specKeyNeitherRootNorAcct "icarus" "1852H/1815H/0H/1/0" "--with-chain-code"
    specKeyNeitherRootNorAcct "icarus" "1852H/1815H/0H/2/0" "--without-chain-code"
    specKeyNeitherRootNorAcct "icarus" "1852H/1815H/0H/2/0" "--with-chain-code"

    specKeyNeitherRootNorAcct "shared" "1854H/1815H/0H/0/0" "--without-chain-code"
    specKeyNeitherRootNorAcct "shared" "1854H/1815H/0H/0/0" "--with-chain-code"
    specKeyNeitherRootNorAcct "shared" "1854H/1815H/0H/1/0" "--without-chain-code"
    specKeyNeitherRootNorAcct "shared" "1854H/1815H/0H/1/0" "--with-chain-code"
    specKeyNeitherRootNorAcct "shared" "1854H/1815H/0H/2/0" "--without-chain-code"
    specKeyNeitherRootNorAcct "shared" "1854H/1815H/0H/2/0" "--with-chain-code"

    specAcctKeyNotExtended "shelley" "1852H/1815H/0H"
    specAcctKeyNotExtended "icarus" "1852H/1815H/0H"
    specAcctKeyNotExtended "shared" "1854H/1815H/0H"

    specRootKeyNotExtended "shelley"
    specRootKeyNotExtended "icarus"
    specRootKeyNotExtended "shared"

    specRootKeyPubPrvHasEqualWalletId "shelley"
    specRootKeyPubPrvHasEqualWalletId "icarus"
    specRootKeyPubPrvHasEqualWalletId "shared"

    specAcctKeyPubPrvHasEqualWalletId "shelley" "1852H/1815H/0H"
    specAcctKeyPubPrvHasEqualWalletId "icarus" "1852H/1815H/0H"
    specAcctKeyPubPrvHasEqualWalletId "shared" "1854H/1815H/0H"

specKeyNeitherRootNorAcct :: String -> String -> String -> SpecWith ()
specKeyNeitherRootNorAcct style path cc = it "fails if key is nether root nor account" $ do
    (out, err) <- cli [ "recovery-phrase", "generate" ] ""
              >>= cli [ "key", "from-recovery-phrase", style ]
              >>= cli [ "key", "child", path ]
              >>= cli [ "key", "public", cc ]
              >>= cli [ "key", "walletid"]
    out `shouldBe` ""
    err `shouldContain` "Invalid human-readable prefix."

specAcctKeyNotExtended :: String -> String -> SpecWith ()
specAcctKeyNotExtended style path = it "fails if account key is not extended" $ do
    (out, err) <- cli [ "recovery-phrase", "generate" ] ""
              >>= cli [ "key", "from-recovery-phrase", style ]
              >>= cli [ "key", "child", path ]
              >>= cli [ "key", "public", "--without-chain-code" ]
              >>= cli [ "key", "walletid"]
    out `shouldBe` ""
    err `shouldContain` "Invalid human-readable prefix."

specRootKeyNotExtended :: String -> SpecWith ()
specRootKeyNotExtended style = it "fails if root key is not extended" $ do
    (out, err) <- cli [ "recovery-phrase", "generate" ] ""
              >>= cli [ "key", "from-recovery-phrase", style ]
              >>= cli [ "key", "public", "--without-chain-code" ]
              >>= cli [ "key", "walletid"]
    out `shouldBe` ""
    err `shouldContain` "Invalid human-readable prefix."

specRootKeyPubPrvHasEqualWalletId :: String -> SpecWith ()
specRootKeyPubPrvHasEqualWalletId style = it "root private key and its public key give the same wallet id" $ do
    xprv <- cli [ "recovery-phrase", "generate" ] ""
        >>= cli [ "key", "from-recovery-phrase", style ]

    walletidFromXPrv <- cli @String [ "key", "walletid"] xprv
    walletidFromXPub <- cli [ "key", "public", "--with-chain-code" ] xprv
                    >>= cli [ "key", "walletid"]

    walletidFromXPrv `shouldBe` walletidFromXPub

specAcctKeyPubPrvHasEqualWalletId :: String -> String -> SpecWith ()
specAcctKeyPubPrvHasEqualWalletId style path = it "root private key and its public key give the same wallet id" $ do
    xprv <- cli [ "recovery-phrase", "generate" ] ""
        >>= cli [ "key", "from-recovery-phrase", style ]
        >>= cli [ "key", "child", path ]

    walletidFromXPrv <- cli @String [ "key", "walletid"] xprv
    walletidFromXPub <- cli [ "key", "public", "--with-chain-code" ] xprv
                    >>= cli [ "key", "walletid"]

    walletidFromXPrv `shouldBe` walletidFromXPub
