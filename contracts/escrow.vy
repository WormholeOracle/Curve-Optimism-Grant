# @version 0.3.9
"""
@title Escrow
@author Llama Risk
@notice Allows owner to transfer native asset or ERC20 to a designated recipient
"""

from vyper.interfaces import ERC20


owner: public(address)
future_owner: public(address)
recipient: public(address)


event CommitOwnership:
    future_owner: address

event ApplyOwnership:
    owner: address

event Transfer:
    token: address
    value: uint256


NATIVE: constant(address) = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE


@external
def __init__(_owner: address, _recipient: address):
    """
    @notice Contract constructor
    @param _owner Contract owner address
    @param _recipient Address that can receive escrowed funds
    """
    self.owner = _owner
    self.recipient = _recipient

    log ApplyOwnership(_owner)


@external
def transfer(_token: address, _value: uint256):
    """
    @notice Transfer an asset to the specified recipient
    @param _token The token to transfer, or NATIVE if transferring the chain native asset
    @param _value The amount of the asset to transfer
    """

    assert msg.sender == self.owner

    if _token == NATIVE:
        send(self.recipient, _value, gas=21000)
    else:
        assert ERC20(_token).transfer(self.recipient, _value, default_return_value=True)

    log Transfer(_token, _value)


@external
def commit_future_owner(_future_owner: address):
    """
    @notice Commit new contract owner
    @param _future_owner The contract owner to commit
    """

    assert msg.sender == self.owner

    self.future_owner = _future_owner

    log CommitOwnership(_future_owner)


@external
def apply_future_owner():
    """
    @notice Apply new contract owner
    """

    assert msg.sender == self.owner

    future_owner: address = self.future_owner
    self.owner = future_owner

    log ApplyOwnership(future_owner)


@payable
@external
def __default__():
    """
    @notice Native token is payable
    """

    assert len(msg.data) == 0

