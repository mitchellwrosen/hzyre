module Network.Interface.Internal where

import           Control.Applicative
import           Data.Map                  (Map)
import qualified Data.Map                  as M
import           Data.Monoid
import           Foreign.C.String          (CString)
import           Foreign.C.Types
import           Foreign.Storable          (Storable(..))
import           Language.C.Inline.Context
import qualified Language.C.Types          as C
import qualified Language.Haskell.TH       as TH

#include "interface.h"

#include <ifaddrs.h>
#include <sys/types.h>

data CInterface = CInterface
    { cifName      :: CString
    , cifAddr      :: CString
    , cifNetmask   :: CString
    , cifBroadcast :: CString
    } deriving Show

instance Storable CInterface where
    sizeOf _ = (#size interface_t)
    alignment _ = alignment (undefined :: CDouble)
    peek ptr = CInterface
        <$> (#peek interface_t, name)      ptr
        <*> (#peek interface_t, addr)      ptr
        <*> (#peek interface_t, netmask)   ptr
        <*> (#peek interface_t, broadcast) ptr
    poke ptr CInterface{..} = do
        (#poke interface_t, name)      ptr cifName
        (#poke interface_t, addr)      ptr cifAddr
        (#poke interface_t, netmask)   ptr cifNetmask
        (#poke interface_t, broadcast) ptr cifBroadcast

ifaceCtx :: Context
ifaceCtx = mempty { ctxTypesTable = ifaceTypesTable }

ifaceTypesTable :: Map C.TypeSpecifier TH.TypeQ
ifaceTypesTable = M.singleton (C.TypeName "interface_t") [t| CInterface |]
