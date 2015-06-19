module Network.Interface
    ( Interface(..)
    , getInterfaces
    , getInterfaces'
    ) where

import           Network.Interface.Internal

import           Control.Applicative
import           Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as BS
import           Data.Monoid
import           Foreign.C.Types
import           Foreign.Marshal.Array
import           Foreign.Ptr
import qualified Language.C.Inline     as C

C.context (C.baseCtx <> ifaceCtx)

C.include "interface.h"

data Interface = Interface
    { ifName      :: ByteString
    , ifAddr      :: ByteString
    , ifNetmask   :: Maybe ByteString
    , ifBroadcast :: Maybe ByteString
    } deriving Show

-- | Get up to 24 IPV4 network interfaces.
getInterfaces :: IO [Interface]
getInterfaces = getInterfaces' 24

-- | Get up to the specified number of network interfaces.
getInterfaces' :: Int -> IO [Interface]
getInterfaces' max_n = c_get_interfaces max_n >>= mapM go
  where
    go :: CInterface -> IO Interface
    go CInterface{..} = Interface
        <$> BS.packCString cifName
        <*> BS.packCString cifAddr
        <*> whenNonNull cifNetmask   BS.packCString
        <*> whenNonNull cifBroadcast BS.packCString

    whenNonNull :: Ptr a -> (Ptr a -> IO b) -> IO (Maybe b)
    whenNonNull ptr f | ptr == nullPtr = return Nothing
                      | otherwise      = Just <$> f ptr

c_get_interfaces :: Int -> IO [CInterface]
c_get_interfaces max_n = do
    let max_n_cint :: CInt = fromIntegral max_n
    allocaArray max_n $ \p -> do
        n <- [C.exp| int {
                 get_interfaces($(interface_t* p), $(int max_n_cint))
             } |]
        peekArray (fromIntegral n) p
