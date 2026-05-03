from fastapi import Depends, HTTPException, status
from typing import Optional
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import SECRET_KEY, ALGORITHM
from app.models.user import User, UserRole

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login", auto_error=False)


from app.core.redis import is_token_blacklisted
from app.core.logger import logger

async def get_current_user(
    token: Optional[str] = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    if not token:
        raise credentials_exception

    # Check if token is blacklisted
    if await is_token_blacklisted(token):
        logger.warning(f"Attempt to use blacklisted token: {token[:10]}...")
        raise credentials_exception

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise credentials_exception

    return user

async def get_current_user_optional(
    token: Optional[str] = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> Optional[User]:
    if not token:
        return None
    try:
        if await is_token_blacklisted(token):
            return None
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            return None
        user = db.query(User).filter(User.id == user_id).first()
        return user
    except Exception:
        return None


def require_roles(*roles):
    """Dependency factory that accepts role names or UserRole enums.

    Normalizes allowed roles to their lowercase values so callers can pass
    either strings like 'admin'/'ADMIN' or `UserRole.ADMIN`.
    """
    # allow callers to pass either multiple args, or a single iterable (list/tuple/set)
    if len(roles) == 1 and isinstance(roles[0], (list, tuple, set)):
        roles_iter = roles[0]
    else:
        roles_iter = roles

    # normalize allowed roles to lower-case role values
    allowed = set()
    for r in roles_iter:
        if isinstance(r, UserRole):
            allowed.add(r.value.lower())
        else:
            allowed.add(str(r).lower())

    def role_checker(current_user: User = Depends(get_current_user)):
        # get current user's role as lower-case string
        current_role = (
            current_user.role.value.lower()
            if isinstance(current_user.role, UserRole)
            else str(current_user.role).lower()
        )

        if current_role not in allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not enough permissions",
            )
        return current_user

    return role_checker