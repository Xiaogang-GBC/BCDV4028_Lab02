// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

// a contract that manages the order status 
contract CarContract {
    // use a enum to indicate the status of order
    enum Status {
        Pending,
        Shipped,
        Cancelled
    }
    // state variable for storing order status
    Status public orderStatus;

    // function to perform delegate call to update the order status in this contract
    // passing a enum value to called contract 
    function set(address _calledAddress) external {
        (bool success, bytes memory returndata) = _calledAddress.delegatecall(
            abi.encodeWithSelector(
                SupplierContract.changeStatus.selector,
                Status.Cancelled
            )
        );

        // if the function call reverted
        if (success == false) {
            // if there is a return reason string
            if (returndata.length > 0) {
                // bubble up any reason for revert
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("Function call reverted");
            }
        }
    }
}

// called contract
contract SupplierContract {
    // same enum as in calling class 
    enum Status {
        Pending,
        Shipped,
        Cancelled
    }
    // same name to the state variable in calling class
    Status public orderStatus;

    // function to be called by calling class to update the order status
    function changeStatus(Status _status) external {
        orderStatus = _status;
    }

}
