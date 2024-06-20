import React from 'react';
import GarageTitle from '../components/GarageTitle';
import LoggedInName from '../components/LoggedInName';
import CarUI from '../components/CarUI';
const CardPage = () =>
{
    return(
        <div>
            <GarageTitle />
            <LoggedInName />
            <CarUI />
        </div>
    );
}
export default CardPage;